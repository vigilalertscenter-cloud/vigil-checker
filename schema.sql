CREATE TABLE IF NOT EXISTS users(
  id INTEGER PRIMARY KEY, name TEXT UNIQUE NOT NULL, login_hash TEXT NOT NULL, ntfy_topic TEXT UNIQUE NOT NULL,
  ntfy_enabled INTEGER NOT NULL DEFAULT 0, created_at INTEGER NOT NULL,
  email TEXT, email_verified INTEGER NOT NULL DEFAULT 0, email_enabled INTEGER NOT NULL DEFAULT 0,
  email_code TEXT, email_code_exp INTEGER, email_code_sent INTEGER NOT NULL DEFAULT 0, unsub_token TEXT,
  reset_hash TEXT, reset_exp INTEGER);
CREATE TABLE IF NOT EXISTS sessions(
  token_hash TEXT PRIMARY KEY, user_id INTEGER NOT NULL, created_at INTEGER NOT NULL);
CREATE TABLE IF NOT EXISTS sites(
  id INTEGER PRIMARY KEY, key TEXT UNIQUE NOT NULL, url TEXT NOT NULL,
  render INTEGER NOT NULL DEFAULT 0, clicks TEXT NOT NULL DEFAULT '[]',
  state TEXT, checked_at INTEGER, last_error TEXT, due_at INTEGER NOT NULL DEFAULT 0, unchanged INTEGER NOT NULL DEFAULT 0);
CREATE TABLE IF NOT EXISTS subs(
  id INTEGER PRIMARY KEY, user_id INTEGER NOT NULL, site_id INTEGER NOT NULL, name TEXT NOT NULL,
  keywords TEXT NOT NULL DEFAULT '[]', only_keywords INTEGER NOT NULL DEFAULT 0,
  active INTEGER NOT NULL DEFAULT 1, created_at INTEGER NOT NULL, UNIQUE(user_id, site_id));
CREATE TABLE IF NOT EXISTS alerts(
  id INTEGER PRIMARY KEY, user_id INTEGER NOT NULL, sub_id INTEGER, site_name TEXT NOT NULL,
  headline TEXT NOT NULL, body TEXT NOT NULL, url TEXT NOT NULL,
  important INTEGER NOT NULL DEFAULT 0, created_at INTEGER NOT NULL);
CREATE TABLE IF NOT EXISTS push_subs(
  id INTEGER PRIMARY KEY, user_id INTEGER NOT NULL, endpoint TEXT UNIQUE NOT NULL,
  p256dh TEXT NOT NULL, auth TEXT NOT NULL, created_at INTEGER NOT NULL);
CREATE TABLE IF NOT EXISTS rl(key TEXT NOT NULL, ts INTEGER NOT NULL);
CREATE TABLE IF NOT EXISTS meta(k TEXT PRIMARY KEY, v TEXT);

CREATE INDEX IF NOT EXISTS idx_alerts_user ON alerts(user_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_subs_site ON subs(site_id, active);
CREATE INDEX IF NOT EXISTS idx_subs_user ON subs(user_id);
CREATE INDEX IF NOT EXISTS idx_push_user ON push_subs(user_id);
CREATE INDEX IF NOT EXISTS idx_sites_due ON sites(due_at);
CREATE INDEX IF NOT EXISTS idx_sessions_user ON sessions(user_id);
CREATE UNIQUE INDEX IF NOT EXISTS idx_users_email ON users(email) WHERE email_verified=1;
CREATE INDEX IF NOT EXISTS idx_rl ON rl(key, ts);

-- Admin broadcasts (announcements to everyone, or to people who follow certain keywords)
CREATE TABLE IF NOT EXISTS broadcasts(
  id INTEGER PRIMARY KEY, title TEXT NOT NULL, body TEXT NOT NULL, url TEXT NOT NULL DEFAULT '', image TEXT NOT NULL DEFAULT '',
  important INTEGER NOT NULL DEFAULT 0, audience TEXT NOT NULL, users INTEGER NOT NULL DEFAULT 0, devices INTEGER NOT NULL DEFAULT 0,
  status TEXT NOT NULL DEFAULT 'sending', cursor INTEGER NOT NULL DEFAULT 0, sent INTEGER NOT NULL DEFAULT 0, failed INTEGER NOT NULL DEFAULT 0,
  created_at INTEGER NOT NULL, finished_at INTEGER);
CREATE TABLE IF NOT EXISTS bc_targets(bid INTEGER NOT NULL, user_id INTEGER NOT NULL, PRIMARY KEY(bid, user_id));
CREATE INDEX IF NOT EXISTS idx_bc_status ON broadcasts(status, id);
