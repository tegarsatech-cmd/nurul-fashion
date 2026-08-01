-- ============================================
-- FIX RLS POLICIES - STEP BY STEP
-- Copy & Paste per bagian, RUN satu per satu
-- ============================================

-- ============================================
-- BAGIAN 1: HAPUS POLICY LAMA
-- ============================================
DROP POLICY IF EXISTS "Allow authenticated all products" ON products;
DROP POLICY IF EXISTS "Allow authenticated all categories" ON categories;
DROP POLICY IF EXISTS "Allow authenticated all gallery" ON gallery;
DROP POLICY IF EXISTS "Allow authenticated all settings" ON settings;
DROP POLICY IF EXISTS "Allow authenticated all contacts" ON contacts;
DROP POLICY IF EXISTS "Allow authenticated all admins" ON admins;

-- ============================================
-- BAGIAN 2: BUAT POLICY BARU (auth.uid() IS NOT NULL)
-- Jalankan setelah BAGIAN 1 berhasil
-- ============================================
CREATE POLICY "Allow authenticated all products" ON products 
    FOR ALL 
    USING (auth.uid() IS NOT NULL) 
    WITH CHECK (auth.uid() IS NOT NULL);

CREATE POLICY "Allow authenticated all categories" ON categories 
    FOR ALL 
    USING (auth.uid() IS NOT NULL) 
    WITH CHECK (auth.uid() IS NOT NULL);

CREATE POLICY "Allow authenticated all gallery" ON gallery 
    FOR ALL 
    USING (auth.uid() IS NOT NULL) 
    WITH CHECK (auth.uid() IS NOT NULL);

CREATE POLICY "Allow authenticated all settings" ON settings 
    FOR ALL 
    USING (auth.uid() IS NOT NULL) 
    WITH CHECK (auth.uid() IS NOT NULL);

CREATE POLICY "Allow authenticated all contacts" ON contacts 
    FOR ALL 
    USING (auth.uid() IS NOT NULL) 
    WITH CHECK (auth.uid() IS NOT NULL);

CREATE POLICY "Allow authenticated all admins" ON admins 
    FOR ALL 
    USING (auth.uid() IS NOT NULL) 
    WITH CHECK (auth.uid() IS NOT NULL);

-- ============================================
-- BAGIAN 3: STORAGE BUCKET POLICIES
-- Jalankan setelah BAGIAN 2 berhasil
-- ============================================
DROP POLICY IF EXISTS "Allow authenticated all objects" ON storage.objects;
DROP POLICY IF EXISTS "Allow public select objects" ON storage.objects;

CREATE POLICY "Allow authenticated all objects" ON storage.objects
    FOR ALL
    USING (auth.uid() IS NOT NULL)
    WITH CHECK (auth.uid() IS NOT NULL);

CREATE POLICY "Allow public select objects" ON storage.objects
    FOR SELECT
    USING (true);

-- ============================================
-- SELESAI!
-- ============================================
-- Verifikasi: jalankan query ini untuk lihat policy aktif
-- SELECT * FROM pg_policies WHERE schemaname = 'public' ORDER BY tablename, policyname;
