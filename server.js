app.post('/api/auth/login', async (req, res) => {
    try {
        const { loginType, identifier } = req.body;
        // ... Code yanu ya Supabase ikhale pano ...
    } catch (error) {
        console.error("VUTO LA SUPABASE DATABASE:", error.message); // <-- Izi zikuonetsani vuto mu Terminal
        return res.status(500).json({ success: false, message: error.message });
    }
});