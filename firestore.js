// firestore.js (DEPRECATED)
// File ini sebelumnya menyediakan wrapper Firestore-like (getDoc/getDocs/etc).
// Untuk memenuhi permintaan migrasi penuh ke Supabase, semua API wrapper Firestore
// dihapus. Gunakan Supabase client langsung (import default) dari lib/supabase.js.

import supabase from "./lib/supabase.js";

// Export default Supabase client so existing imports like `import db from "../firestore.js"` continue to work.
export default supabase;

