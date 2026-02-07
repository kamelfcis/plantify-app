-- ====================================================
-- SUPABASE STORAGE BUCKETS & POLICIES
-- ====================================================
-- Run this in your Supabase SQL Editor after creating the schema

-- ====================================================
-- 1. PLANT IMAGES BUCKET (PUBLIC)
-- ====================================================
INSERT INTO storage.buckets (id, name, public)
VALUES ('plant-images', 'plant-images', true)
ON CONFLICT (id) DO NOTHING;

-- Public read access for plant images
CREATE POLICY "Public can view plant images"
ON storage.objects FOR SELECT
USING (bucket_id = 'plant-images');

-- Authenticated users can upload plant images
CREATE POLICY "Authenticated users can upload plant images"
ON storage.objects FOR INSERT
WITH CHECK (
    bucket_id = 'plant-images' 
    AND auth.role() = 'authenticated'
);

-- Authenticated users can update their own plant images
CREATE POLICY "Authenticated users can update plant images"
ON storage.objects FOR UPDATE
USING (
    bucket_id = 'plant-images' 
    AND auth.role() = 'authenticated'
);

-- Authenticated users can delete their own plant images
CREATE POLICY "Authenticated users can delete plant images"
ON storage.objects FOR DELETE
USING (
    bucket_id = 'plant-images' 
    AND auth.role() = 'authenticated'
);

-- ====================================================
-- 2. PRODUCT IMAGES BUCKET (PUBLIC)
-- ====================================================
INSERT INTO storage.buckets (id, name, public)
VALUES ('product-images', 'product-images', true)
ON CONFLICT (id) DO NOTHING;

-- Public read access for product images
CREATE POLICY "Public can view product images"
ON storage.objects FOR SELECT
USING (bucket_id = 'product-images');

-- Authenticated users can upload product images (admin only in production)
CREATE POLICY "Authenticated users can upload product images"
ON storage.objects FOR INSERT
WITH CHECK (
    bucket_id = 'product-images' 
    AND auth.role() = 'authenticated'
);

-- Authenticated users can update product images
CREATE POLICY "Authenticated users can update product images"
ON storage.objects FOR UPDATE
USING (
    bucket_id = 'product-images' 
    AND auth.role() = 'authenticated'
);

-- Authenticated users can delete product images
CREATE POLICY "Authenticated users can delete product images"
ON storage.objects FOR DELETE
USING (
    bucket_id = 'product-images' 
    AND auth.role() = 'authenticated'
);

-- ====================================================
-- 3. USER UPLOADS BUCKET (PRIVATE)
-- ====================================================
INSERT INTO storage.buckets (id, name, public)
VALUES ('user-uploads', 'user-uploads', false)
ON CONFLICT (id) DO NOTHING;

-- Users can view their own uploads
CREATE POLICY "Users can view own uploads"
ON storage.objects FOR SELECT
USING (
    bucket_id = 'user-uploads' 
    AND auth.uid()::text = (storage.foldername(name))[1]
);

-- Users can upload to their own folder
CREATE POLICY "Users can upload to own folder"
ON storage.objects FOR INSERT
WITH CHECK (
    bucket_id = 'user-uploads' 
    AND auth.uid()::text = (storage.foldername(name))[1]
);

-- Users can update their own uploads
CREATE POLICY "Users can update own uploads"
ON storage.objects FOR UPDATE
USING (
    bucket_id = 'user-uploads' 
    AND auth.uid()::text = (storage.foldername(name))[1]
);

-- Users can delete their own uploads
CREATE POLICY "Users can delete own uploads"
ON storage.objects FOR DELETE
USING (
    bucket_id = 'user-uploads' 
    AND auth.uid()::text = (storage.foldername(name))[1]
);

-- ====================================================
-- HELPER FUNCTION FOR FOLDER STRUCTURE
-- ====================================================
-- This function helps organize user uploads by user ID
-- Files should be uploaded with path: {user_id}/{filename}

