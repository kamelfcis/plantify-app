-- ====================================================
-- PLANT CARE & MARKETPLACE APP - SUPABASE SCHEMA
-- ====================================================
-- This script creates all necessary tables, RLS policies, and storage buckets
-- Run this in your Supabase SQL Editor

-- ====================================================
-- 1. PROFILES TABLE
-- ====================================================
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
    full_name TEXT,
    email TEXT,
    avatar_url TEXT,
    phone TEXT,
    address TEXT,
    city TEXT,
    zip_code TEXT,
    country TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- Policies for profiles
CREATE POLICY "Users can view own profile"
    ON public.profiles FOR SELECT
    USING (auth.uid() = id);

CREATE POLICY "Users can update own profile"
    ON public.profiles FOR UPDATE
    USING (auth.uid() = id);

CREATE POLICY "Users can insert own profile"
    ON public.profiles FOR INSERT
    WITH CHECK (auth.uid() = id);

-- ====================================================
-- 2. PLANTS MASTER TABLE
-- ====================================================
CREATE TABLE IF NOT EXISTS public.plants (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    name TEXT NOT NULL,
    scientific_name TEXT,
    description TEXT,
    category TEXT NOT NULL, -- Indoor, Outdoor, Succulent, Herb, etc.
    care_instructions JSONB, -- {watering, sunlight, humidity, temperature}
    image_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE public.plants ENABLE ROW LEVEL SECURITY;

-- Policies for plants (public read, admin write)
CREATE POLICY "Anyone can view plants"
    ON public.plants FOR SELECT
    USING (true);

-- ====================================================
-- 3. USER PLANTS TABLE
-- ====================================================
CREATE TABLE IF NOT EXISTS public.user_plants (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    plant_id UUID REFERENCES public.plants(id) ON DELETE SET NULL,
    name TEXT NOT NULL,
    scientific_name TEXT,
    health_status TEXT DEFAULT 'Good', -- Excellent, Good, Fair, Poor
    growth_percentage INTEGER DEFAULT 50,
    date_added DATE DEFAULT CURRENT_DATE,
    next_watering_date DATE,
    notes TEXT,
    image_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE public.user_plants ENABLE ROW LEVEL SECURITY;

-- Policies for user_plants
CREATE POLICY "Users can view own plants"
    ON public.user_plants FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own plants"
    ON public.user_plants FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own plants"
    ON public.user_plants FOR UPDATE
    USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own plants"
    ON public.user_plants FOR DELETE
    USING (auth.uid() = user_id);

-- ====================================================
-- 4. PLANT HEALTH HISTORY
-- ====================================================
CREATE TABLE IF NOT EXISTS public.plant_health_history (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_plant_id UUID REFERENCES public.user_plants(id) ON DELETE CASCADE NOT NULL,
    health_status TEXT NOT NULL,
    growth_percentage INTEGER,
    notes TEXT,
    image_url TEXT,
    recorded_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE public.plant_health_history ENABLE ROW LEVEL SECURITY;

-- Policies for plant_health_history
CREATE POLICY "Users can view own plant history"
    ON public.plant_health_history FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM public.user_plants
            WHERE user_plants.id = plant_health_history.user_plant_id
            AND user_plants.user_id = auth.uid()
        )
    );

CREATE POLICY "Users can insert own plant history"
    ON public.plant_health_history FOR INSERT
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.user_plants
            WHERE user_plants.id = plant_health_history.user_plant_id
            AND user_plants.user_id = auth.uid()
        )
    );

-- ====================================================
-- 5. REMINDERS TABLE
-- ====================================================
CREATE TABLE IF NOT EXISTS public.reminders (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    user_plant_id UUID REFERENCES public.user_plants(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    reminder_type TEXT DEFAULT 'watering', -- watering, fertilizing, pruning, etc.
    scheduled_time TIME NOT NULL,
    repeat_frequency TEXT DEFAULT 'Daily', -- Daily, Weekly, Once
    tips TEXT, -- Care tips to show in notification
    is_active BOOLEAN DEFAULT true,
    notification_id INTEGER, -- Local notification ID
    last_triggered_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE public.reminders ENABLE ROW LEVEL SECURITY;

-- Policies for reminders
CREATE POLICY "Users can view own reminders"
    ON public.reminders FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own reminders"
    ON public.reminders FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own reminders"
    ON public.reminders FOR UPDATE
    USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own reminders"
    ON public.reminders FOR DELETE
    USING (auth.uid() = user_id);

-- ====================================================
-- 6. MARKETPLACE PRODUCTS TABLE
-- ====================================================
CREATE TABLE IF NOT EXISTS public.products (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT,
    price DECIMAL(10, 2) NOT NULL,
    category TEXT NOT NULL,
    image_url TEXT,
    in_stock BOOLEAN DEFAULT true,
    stock_quantity INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE public.products ENABLE ROW LEVEL SECURITY;

-- Policies for products (public read)
CREATE POLICY "Anyone can view products"
    ON public.products FOR SELECT
    USING (true);

-- ====================================================
-- 7. ORDERS TABLE
-- ====================================================
CREATE TABLE IF NOT EXISTS public.orders (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    order_number TEXT UNIQUE NOT NULL,
    total_amount DECIMAL(10, 2) NOT NULL,
    shipping_address JSONB NOT NULL, -- {fullName, email, phone, address, city, zipCode, country}
    status TEXT DEFAULT 'pending', -- pending, processing, shipped, delivered, cancelled
    is_gift BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE public.orders ENABLE ROW LEVEL SECURITY;

-- Policies for orders
CREATE POLICY "Users can view own orders"
    ON public.orders FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own orders"
    ON public.orders FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own orders"
    ON public.orders FOR UPDATE
    USING (auth.uid() = user_id);

-- ====================================================
-- 8. ORDER ITEMS TABLE
-- ====================================================
CREATE TABLE IF NOT EXISTS public.order_items (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    order_id UUID REFERENCES public.orders(id) ON DELETE CASCADE NOT NULL,
    product_id UUID REFERENCES public.products(id) ON DELETE SET NULL,
    product_name TEXT NOT NULL,
    product_price DECIMAL(10, 2) NOT NULL,
    quantity INTEGER NOT NULL DEFAULT 1,
    subtotal DECIMAL(10, 2) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE public.order_items ENABLE ROW LEVEL SECURITY;

-- Policies for order_items
CREATE POLICY "Users can view own order items"
    ON public.order_items FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM public.orders
            WHERE orders.id = order_items.order_id
            AND orders.user_id = auth.uid()
        )
    );

CREATE POLICY "Users can insert own order items"
    ON public.order_items FOR INSERT
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.orders
            WHERE orders.id = order_items.order_id
            AND orders.user_id = auth.uid()
        )
    );

-- ====================================================
-- 9. GIFTS TABLE
-- ====================================================
CREATE TABLE IF NOT EXISTS public.gifts (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    order_id UUID REFERENCES public.orders(id) ON DELETE CASCADE NOT NULL,
    sender_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    receiver_name TEXT NOT NULL,
    receiver_email TEXT NOT NULL,
    receiver_address JSONB NOT NULL,
    gift_message TEXT,
    delivery_tracking TEXT,
    delivered_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE public.gifts ENABLE ROW LEVEL SECURITY;

-- Policies for gifts
CREATE POLICY "Users can view own sent gifts"
    ON public.gifts FOR SELECT
    USING (auth.uid() = sender_id);

CREATE POLICY "Users can insert own gifts"
    ON public.gifts FOR INSERT
    WITH CHECK (auth.uid() = sender_id);

-- ====================================================
-- INDEXES FOR PERFORMANCE
-- ====================================================
CREATE INDEX IF NOT EXISTS idx_user_plants_user_id ON public.user_plants(user_id);
CREATE INDEX IF NOT EXISTS idx_user_plants_plant_id ON public.user_plants(plant_id);
CREATE INDEX IF NOT EXISTS idx_plant_health_history_user_plant_id ON public.plant_health_history(user_plant_id);
CREATE INDEX IF NOT EXISTS idx_reminders_user_id ON public.reminders(user_id);
CREATE INDEX IF NOT EXISTS idx_orders_user_id ON public.orders(user_id);
CREATE INDEX IF NOT EXISTS idx_order_items_order_id ON public.order_items(order_id);
CREATE INDEX IF NOT EXISTS idx_gifts_sender_id ON public.gifts(sender_id);
CREATE INDEX IF NOT EXISTS idx_gifts_order_id ON public.gifts(order_id);

-- ====================================================
-- FUNCTIONS & TRIGGERS
-- ====================================================
-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Triggers for updated_at
CREATE TRIGGER update_profiles_updated_at BEFORE UPDATE ON public.profiles
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_plants_updated_at BEFORE UPDATE ON public.plants
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_user_plants_updated_at BEFORE UPDATE ON public.user_plants
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_reminders_updated_at BEFORE UPDATE ON public.reminders
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_products_updated_at BEFORE UPDATE ON public.products
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_orders_updated_at BEFORE UPDATE ON public.orders
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Function to generate order number
CREATE OR REPLACE FUNCTION generate_order_number()
RETURNS TEXT AS $$
BEGIN
    RETURN 'ORD-' || TO_CHAR(NOW(), 'YYYYMMDD') || '-' || LPAD(NEXTVAL('order_number_seq')::TEXT, 6, '0');
END;
$$ LANGUAGE plpgsql;

-- Sequence for order numbers
CREATE SEQUENCE IF NOT EXISTS order_number_seq START 1;

-- ====================================================
-- SAMPLE DATA (OPTIONAL)
-- ====================================================
-- Insert sample plants
INSERT INTO public.plants (name, scientific_name, category, care_instructions) VALUES
    ('Monstera Deliciosa', 'Monstera deliciosa', 'Indoor', '{"watering": "Once a week", "sunlight": "Bright indirect", "humidity": "High", "temperature": "65-85°F"}'::jsonb),
    ('Snake Plant', 'Sansevieria trifasciata', 'Indoor', '{"watering": "Every 2-3 weeks", "sunlight": "Low to bright", "humidity": "Low", "temperature": "60-80°F"}'::jsonb),
    ('Pothos', 'Epipremnum aureum', 'Indoor', '{"watering": "When top inch is dry", "sunlight": "Bright indirect", "humidity": "Moderate", "temperature": "65-75°F"}'::jsonb)
ON CONFLICT DO NOTHING;

-- Insert sample products
INSERT INTO public.products (name, description, price, category, in_stock, stock_quantity) VALUES
    ('Monstera Deliciosa', 'Beautiful tropical plant with unique split leaves', 29.99, 'Indoor', true, 50),
    ('Snake Plant', 'Low-maintenance plant perfect for beginners', 19.99, 'Indoor', true, 100),
    ('Pothos Golden', 'Fast-growing trailing plant with golden variegation', 15.99, 'Indoor', true, 75),
    ('Lavender', 'Fragrant herb perfect for outdoor gardens', 12.99, 'Outdoor', true, 60),
    ('Aloe Vera', 'Medicinal succulent with healing properties', 9.99, 'Succulent', true, 80),
    ('Peace Lily', 'Elegant flowering plant that purifies air', 24.99, 'Indoor', true, 40)
ON CONFLICT DO NOTHING;

