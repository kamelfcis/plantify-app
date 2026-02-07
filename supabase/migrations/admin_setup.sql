-- ====================================================
-- ADMIN SETUP MIGRATION
-- ====================================================

-- Add is_blocked column to profiles table
ALTER TABLE public.profiles
ADD COLUMN IF NOT EXISTS is_blocked BOOLEAN DEFAULT false;

-- Add last_seen column to profiles for online status tracking
ALTER TABLE public.profiles
ADD COLUMN IF NOT EXISTS last_seen TIMESTAMP WITH TIME ZONE DEFAULT NOW();

-- Create admin policy to allow reading all profiles (using service role key or RLS bypass)
-- For admin operations, we use the Supabase service role or RLS policies

-- Policy: Allow reading all profiles for admin dashboard
-- We use a simple approach: the admin reads via the service role or we create a public read policy
CREATE POLICY "Allow reading all profiles for admin"
    ON public.profiles FOR SELECT
    USING (true);

-- Policy: Allow admin to update any profile (for blocking)
CREATE POLICY "Allow updating all profiles for admin"
    ON public.profiles FOR UPDATE
    USING (true);

-- Allow reading all orders (admin)
CREATE POLICY "Allow reading all orders for admin"
    ON public.orders FOR SELECT
    USING (true);

-- Allow updating all orders (admin - for status change)
CREATE POLICY "Allow updating all orders for admin"
    ON public.orders FOR UPDATE
    USING (true);

-- Allow reading all order items (admin)
CREATE POLICY "Allow reading all order items for admin"
    ON public.order_items FOR SELECT
    USING (true);

-- Allow reading all gifts (admin)
CREATE POLICY "Allow reading all gifts for admin"
    ON public.gifts FOR SELECT
    USING (true);

-- Allow admin to insert/update/delete products
CREATE POLICY "Allow admin to insert products"
    ON public.products FOR INSERT
    WITH CHECK (true);

CREATE POLICY "Allow admin to update products"
    ON public.products FOR UPDATE
    USING (true);

CREATE POLICY "Allow admin to delete products"
    ON public.products FOR DELETE
    USING (true);

-- ====================================================
-- STORAGE POLICIES FOR ADMIN (product-images bucket)
-- ====================================================
-- Allow anyone to upload product images (for admin panel without auth session)
CREATE POLICY "Allow public upload to product images"
    ON storage.objects FOR INSERT
    WITH CHECK (bucket_id = 'product-images');

-- Allow anyone to update product images
CREATE POLICY "Allow public update product images"
    ON storage.objects FOR UPDATE
    USING (bucket_id = 'product-images');

-- Allow anyone to delete product images
CREATE POLICY "Allow public delete product images"
    ON storage.objects FOR DELETE
    USING (bucket_id = 'product-images');

-- ====================================================
-- ENABLE REALTIME ON ORDERS TABLE
-- ====================================================
-- This enables Supabase Realtime (Postgres Changes) so the app
-- can listen for new orders (admin) and status updates (user).
ALTER PUBLICATION supabase_realtime ADD TABLE public.orders;

-- Enable full replica identity so UPDATE events include old record
-- (needed to compare old status vs new status)
ALTER TABLE public.orders REPLICA IDENTITY FULL;

