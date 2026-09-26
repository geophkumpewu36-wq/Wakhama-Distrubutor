WAKHAMA DISTRIBUTOR — SUPABASE + VERCEL

1. Supabase
Project URL already set in index.html:
https://aapatwzdkgjvwezbhmoz.supabase.co

Open Supabase -> SQL Editor -> paste setup.sql -> Run.

2. Get API key
Supabase -> Project Settings -> API
Copy the Publishable key (or anon key if your dashboard shows that).
Open public/index.html and replace:
PASTE_YOUR_SUPABASE_ANON_OR_PUBLISHABLE_KEY_HERE
with that key.

NEVER put the service_role/secret key in index.html.

3. Authentication
Supabase -> Authentication -> Providers -> Email should be enabled.
For easy testing you can disable "Confirm email". For production, email confirmation is recommended.

4. Vercel
Upload this folder as a GitHub repo and import it into Vercel.
No Node server is required for this version.
Framework: Other
Build command: leave empty
Output directory: public
If Vercel asks for root directory, use the project root and set the output to public.

5. Important earnings rule
Current demo rate is K1 per approved play.
Change record_stream() later to your real royalty formula. Do not claim a fixed Spotify royalty rate; Spotify payouts are not a simple fixed amount per stream.

6. K5,000 payment
The site currently records the transaction/reference and shows it to the artist.
Automatic Airtel Money/TNM Mpamba payment verification needs the merchant/API credentials and provider integration.

7. Spotify
The site can store Spotify status/link. Actual automatic delivery to Spotify requires an authorized distributor/partner API or distribution agreement. Do not promise instant Spotify publishing until that integration is connected.

8. Admin
For security, admin actions should be done from a protected server/Edge Function using a service-role secret. Never expose the service-role key in frontend code.
