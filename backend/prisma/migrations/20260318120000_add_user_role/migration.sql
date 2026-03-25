-- CreateEnum
CREATE TYPE "UserRole" AS ENUM ('student', 'employer', 'admin');

-- AlterTable: convert "User"."role" from TEXT to UserRole without data loss
-- Map existing 'user' -> 'student', 'admin' -> 'admin', anything else -> 'student'
ALTER TABLE "User" ADD COLUMN "role_new" "UserRole" NOT NULL DEFAULT 'student';

UPDATE "User" SET "role_new" = CASE
  WHEN "role" = 'admin' THEN 'admin'::"UserRole"
  ELSE 'student'::"UserRole"
END;

ALTER TABLE "User" DROP COLUMN "role";

ALTER TABLE "User" RENAME COLUMN "role_new" TO "role";

ALTER TABLE "User" ALTER COLUMN "role" SET DEFAULT 'student';
