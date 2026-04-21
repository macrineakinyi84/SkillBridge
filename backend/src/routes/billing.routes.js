const express = require('express');
const Stripe = require('stripe');

const prisma = require('../lib/prisma');
const { authenticate, requireEmployer } = require('../middleware/auth');
const { asyncHandler } = require('../middleware/errorHandler');
const { getStripeSecretKey, getEnv } = require('../config/env');

const router = express.Router();

function stripeClient() {
  return new Stripe(getStripeSecretKey());
}

router.post('/create-checkout-session', authenticate, requireEmployer, asyncHandler(async (req, res) => {
  const userId = req.user.userId;
  const user = await prisma?.user.findUnique({ where: { id: userId } });
  if (!user) return res.status(404).json({ success: false, error: { message: 'Employer not found' } });

  const priceId = getEnv('STRIPE_PRICE_ID');
  const appBase = getEnv('APP_BASE_URL', 'http://localhost:3000');
  if (!priceId) return res.status(400).json({ success: false, error: { message: 'STRIPE_PRICE_ID missing' } });

  const stripe = stripeClient();
  const customer = user.stripeCustomerId
    ? await stripe.customers.retrieve(user.stripeCustomerId).catch(() => null)
    : null;
  let customerId = user.stripeCustomerId;
  if (!customer || customer.deleted) {
    const created = await stripe.customers.create({
      email: user.email,
      metadata: { userId },
    });
    customerId = created.id;
    await prisma.user.update({ where: { id: userId }, data: { stripeCustomerId: customerId } });
  }

  const session = await stripe.checkout.sessions.create({
    mode: 'subscription',
    customer: customerId,
    line_items: [{ price: priceId, quantity: 1 }],
    success_url: `${appBase}/employer/dashboard?billing=success`,
    cancel_url: `${appBase}/employer/dashboard?billing=cancelled`,
    metadata: { userId },
  });

  return res.json({ success: true, data: { url: session.url } });
}));

router.get('/status', authenticate, requireEmployer, asyncHandler(async (req, res) => {
  const userId = req.user.userId;
  const user = await prisma?.user.findUnique({ where: { id: userId } });
  if (!user) return res.status(404).json({ success: false, error: { message: 'Employer not found' } });
  return res.json({
    success: true,
    data: {
      plan: user.subscriptionPlan,
      status: user.subscriptionStatus,
      currentPeriodEnd: user.subscriptionCurrentPeriodEnd?.toISOString() ?? null,
      canPostJobs: user.subscriptionStatus === 'active',
    },
  });
}));

router.post('/webhook', asyncHandler(async (req, res) => {
  const webhookSecret = getEnv('STRIPE_WEBHOOK_SECRET');
  if (!webhookSecret) return res.status(400).send('Missing STRIPE_WEBHOOK_SECRET');
  const sig = req.headers['stripe-signature'];
  if (!sig) return res.status(400).send('Missing signature');

  const stripe = stripeClient();
  let event;
  try {
    event = stripe.webhooks.constructEvent(req.body, sig, webhookSecret);
  } catch (err) {
    return res.status(400).send(`Webhook Error: ${err.message}`);
  }

  if (event.type === 'checkout.session.completed') {
    const session = event.data.object;
    const userId = session.metadata?.userId;
    if (userId) {
      await prisma?.user.update({
        where: { id: userId },
        data: {
          subscriptionPlan: 'pro',
          subscriptionStatus: 'active',
          stripeSubscriptionId: session.subscription ?? null,
        },
      });
    }
  }

  if (event.type === 'customer.subscription.deleted') {
    const subscription = event.data.object;
    const subId = subscription.id;
    await prisma?.user.updateMany({
      where: { stripeSubscriptionId: subId },
      data: {
        subscriptionPlan: 'free',
        subscriptionStatus: 'inactive',
      },
    });
  }

  return res.json({ received: true });
}));

module.exports = router;

