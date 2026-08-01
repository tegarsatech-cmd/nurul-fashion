// lib/supabase.js
// Inisialisasi Supabase Client

import { createClient } from "https://esm.sh/@supabase/supabase-js@2.39.0";

const supabaseUrl = "https://ejgqjxktwlpodhbymidj.supabase.co";
const supabaseKey = "sb_publishable_GwrUMlhubSxZ1VIcNKSFsA_-AKrjOG0";

const supabase = createClient(supabaseUrl, supabaseKey);

console.log("Supabase client initialized");

export default supabase;

