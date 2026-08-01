-- ============================================

-- ============================================
-- COPY & PASTE SEMUA INI ke Supabase SQL Editor, lalu RUN

-- 1. Enable UUID
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================
-- 2. BUAT TABEL (CREATE IF NOT EXISTS)
-- ============================================

-- settings
CREATE TABLE IF NOT EXISTS settings (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    nama_toko TEXT,
    wa_number TEXT,
    email TEXT,
    jam_operasional TEXT,
    alamat TEXT,
    instagram TEXT,
    facebook TEXT,
    tiktok TEXT,
    maps_url TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- categories
CREATE TABLE IF NOT EXISTS categories (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    nama TEXT NOT NULL,
    icon TEXT DEFAULT 'fas fa-tag',
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- products
CREATE TABLE IF NOT EXISTS products (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    nama TEXT NOT NULL,
    kategori TEXT,
    harga BIGINT DEFAULT 0,
    stok TEXT DEFAULT 'Tersedia',
    ukuran TEXT,
    warna TEXT,
    gambar TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- gallery
CREATE TABLE IF NOT EXISTS gallery (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    judul TEXT,
    gambar TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- contacts
CREATE TABLE IF NOT EXISTS contacts (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    nama TEXT,
    email TEXT,
    pesan TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- admins
CREATE TABLE IF NOT EXISTS admins (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    email TEXT UNIQUE NOT NULL,
    nama TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- 3. TAMBAH KOLOM YANG HILANG (jika tabel sudah ada)
-- ============================================
ALTER TABLE settings ADD COLUMN IF NOT EXISTS alamat TEXT;
ALTER TABLE settings ADD COLUMN IF NOT EXISTS maps_url TEXT;
ALTER TABLE categories ADD COLUMN IF NOT EXISTS icon TEXT DEFAULT 'fas fa-tag';
ALTER TABLE categories ADD COLUMN IF NOT EXISTS created_at TIMESTAMPTZ DEFAULT NOW();
ALTER TABLE products ADD COLUMN IF NOT EXISTS created_at TIMESTAMPTZ DEFAULT NOW();
ALTER TABLE gallery ADD COLUMN IF NOT EXISTS created_at TIMESTAMPTZ DEFAULT NOW();
ALTER TABLE contacts ADD COLUMN IF NOT EXISTS created_at TIMESTAMPTZ DEFAULT NOW();
ALTER TABLE admins ADD COLUMN IF NOT EXISTS created_at TIMESTAMPTZ DEFAULT NOW();

-- ============================================
-- 4. UPDATE REALTIME (aman — tidak error "already member")
-- ============================================
DO $$
DECLARE
    tbl TEXT;
    tbl_id OID;
    pub_id OID;
BEGIN
    -- Ambil OID publikasi supabase_realtime
    SELECT oid INTO pub_id FROM pg_publication WHERE pubname = 'supabase_realtime';

    IF pub_id IS NULL THEN
        RAISE EXCEPTION 'Publikasi "supabase_realtime" tidak ditemukan!';
    END IF;

    FOREACH tbl IN ARRAY ARRAY['categories', 'products', 'gallery', 'settings', 'contacts']
    LOOP
        -- Ambil OID relasi (tabel)
        SELECT oid INTO tbl_id FROM pg_class WHERE relname = tbl AND relnamespace = (SELECT oid FROM pg_namespace WHERE nspname = 'public');

        IF tbl_id IS NULL THEN
            RAISE NOTICE 'Tabel "%" tidak ditemukan, dilewati.', tbl;
            CONTINUE;
        END IF;

        -- Cek apakah tabel sudah terdaftar di publikasi
        IF EXISTS (SELECT 1 FROM pg_publication_rel WHERE prpubid = pub_id AND prrelid = tbl_id) THEN
            RAISE NOTICE 'Tabel "%" sudah menjadi anggota "supabase_realtime", dilewati.', tbl;
        ELSE
            EXECUTE format('ALTER PUBLICATION supabase_realtime ADD TABLE %I;', tbl);
            RAISE NOTICE 'Tabel "%" berhasil ditambahkan ke "supabase_realtime".', tbl;
        END IF;
    END LOOP;
END $$;

-- ============================================
-- 5. ROW LEVEL SECURITY (RLS) POLICIES
-- ============================================
-- Izinkan anonim (public) untuk SELECT dan INSERT (untuk seed data & kontak)
-- Izinkan authenticated (admin) untuk ALL

-- Aktifkan RLS di semua tabel
ALTER TABLE IF EXISTS categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS products ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS gallery ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS contacts ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS admins ENABLE ROW LEVEL SECURITY;

-- Hapus policy lama (biar bisa di-run berulang kali)
DROP POLICY IF EXISTS "Allow anon SELECT categories" ON categories;
DROP POLICY IF EXISTS "Allow anon SELECT products" ON products;
DROP POLICY IF EXISTS "Allow anon SELECT gallery" ON gallery;
DROP POLICY IF EXISTS "Allow anon SELECT settings" ON settings;
DROP POLICY IF EXISTS "Allow anon SELECT contacts" ON contacts;
DROP POLICY IF EXISTS "Allow anon INSERT categories" ON categories;
DROP POLICY IF EXISTS "Allow anon INSERT products" ON products;
DROP POLICY IF EXISTS "Allow anon INSERT gallery" ON gallery;
DROP POLICY IF EXISTS "Allow anon INSERT settings" ON settings;
DROP POLICY IF EXISTS "Allow anon INSERT contacts" ON contacts;
DROP POLICY IF EXISTS "Allow authenticated all categories" ON categories;
DROP POLICY IF EXISTS "Allow authenticated all products" ON products;
DROP POLICY IF EXISTS "Allow authenticated all gallery" ON gallery;
DROP POLICY IF EXISTS "Allow authenticated all settings" ON settings;
DROP POLICY IF EXISTS "Allow authenticated all contacts" ON contacts;
DROP POLICY IF EXISTS "Allow authenticated all admins" ON admins;

-- Policy: anonim boleh SELECT (baca data)
CREATE POLICY "Allow anon SELECT categories" ON categories FOR SELECT USING (true);
CREATE POLICY "Allow anon SELECT products" ON products FOR SELECT USING (true);
CREATE POLICY "Allow anon SELECT gallery" ON gallery FOR SELECT USING (true);
CREATE POLICY "Allow anon SELECT settings" ON settings FOR SELECT USING (true);
CREATE POLICY "Allow anon SELECT contacts" ON contacts FOR SELECT USING (true);

-- Policy: anonim boleh INSERT (untuk seed data + kontak)
CREATE POLICY "Allow anon INSERT categories" ON categories FOR INSERT WITH CHECK (true);
CREATE POLICY "Allow anon INSERT products" ON products FOR INSERT WITH CHECK (true);
CREATE POLICY "Allow anon INSERT gallery" ON gallery FOR INSERT WITH CHECK (true);
CREATE POLICY "Allow anon INSERT settings" ON settings FOR INSERT WITH CHECK (true);
CREATE POLICY "Allow anon INSERT contacts" ON contacts FOR INSERT WITH CHECK (true);

-- Policy: authenticated (admin) boleh ALL
CREATE POLICY "Allow authenticated all categories" ON categories FOR ALL USING (auth.role() = 'authenticated') WITH CHECK (auth.role() = 'authenticated');
CREATE POLICY "Allow authenticated all products" ON products FOR ALL USING (auth.role() = 'authenticated') WITH CHECK (auth.role() = 'authenticated');
CREATE POLICY "Allow authenticated all gallery" ON gallery FOR ALL USING (auth.role() = 'authenticated') WITH CHECK (auth.role() = 'authenticated');
CREATE POLICY "Allow authenticated all settings" ON settings FOR ALL USING (auth.role() = 'authenticated') WITH CHECK (auth.role() = 'authenticated');
CREATE POLICY "Allow authenticated all contacts" ON contacts FOR ALL USING (auth.role() = 'authenticated') WITH CHECK (auth.role() = 'authenticated');
CREATE POLICY "Allow authenticated all admins" ON admins FOR ALL USING (auth.role() = 'authenticated') WITH CHECK (auth.role() = 'authenticated');

-- ============================================
-- 6. REFRESH SCHEMA CACHE (WAJIB!)
-- ============================================
SELECT pg_notify('pgrst', 'reload schema');

-- ============================================
-- 7. STORAGE BUCKETS (buat manual di Dashboard)
-- ============================================
-- Buka Supabase Dashboard > Storage > New Bucket
-- Buat 3 bucket:
--   - products (Public)
--   - gallery (Public)
--   - website (Public)
