import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.39.0';

const supabaseUrl = 'https://ejgqjxktwlpodhbymidj.supabase.co';
const supabaseKey = 'sb_publishable_GwrUMlhubSxZ1VIcNKSFsA_-AKrjOG0';

const supabase = createClient(supabaseUrl, supabaseKey, {
    auth: {
        persistSession: true,
        detectSessionInUrl: true
    }
});

export async function signInWithEmailAndPassword(email, password) {
    const { data, error } = await supabase.auth.signInWithPassword({ email, password });
    if (error) throw error;
    return data;
}

export async function signOut() {
    const { error } = await supabase.auth.signOut();
    if (error) throw error;
}

export function onAuthStateChanged(callback) {
    if (typeof callback !== 'function') return;
    supabase.auth.onAuthStateChange((event, session) => {
        callback(session?.user ?? null);
    });
    supabase.auth.getUser().then(({ data }) => {
        callback(data?.user ?? null);
    }).catch((error) => {
        console.error('Auth getUser error:', error);
        callback(null);
    });
}

export default supabase;
