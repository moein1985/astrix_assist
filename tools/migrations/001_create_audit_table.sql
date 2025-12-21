-- Migration: create audit table for AMI listen/playback actions
-- Run this on your DB to create the audit table used for persistent logging.

CREATE TABLE IF NOT EXISTS ami_audit (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id TEXT,
  action TEXT NOT NULL,
  target TEXT,
  recording_id TEXT,
  job_id TEXT,
  reason TEXT,
  timestamp TEXT NOT NULL,
  duration INTEGER,
  meta JSON
);

CREATE INDEX IF NOT EXISTS idx_ami_audit_job ON ami_audit(job_id);
CREATE INDEX IF NOT EXISTS idx_ami_audit_user ON ami_audit(user_id);
