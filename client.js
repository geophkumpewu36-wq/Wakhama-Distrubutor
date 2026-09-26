// Supabase client yanu
const SUPABASE_URL = 'https://cujvhqwnxdgxawylyzsp.supabase.co/rest/v1/' //
const SUPABASE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImN1anZocXdueGRneGF3eWx5enNwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTA0MDc4OTgsImV4cCI6MjEwNTk4Mzg5OH0.niDWmseYMc6zvP4eqUBA7NNF9gsl5p4u4X05rN-tVGw' // 

const supabase = window.supabase.createClient(SUPABASE_URL, SUPABASE_KEY)

// Yang'ana ngati munthu walowa kale
async function checkUser() {
  const { data: { session } } = await supabase.auth.getSession()
  console.log("Session:", session)
  return session
}

document.getElementById('loginForm').addEventListener('submit', async (e) => {
  e.preventDefault() // IYI NDIYOFUNIKA KWAMBIRI, ngati mulibe imeneyi, ndiye ndiye imathawitsa

  const email = document.getElementById('email').value
  const password = document.getElementById('password').value

  const { data, error } = await supabase.auth.signInWithPassword({ email, password })

  if(error){
    alert(error.message)
  } else {
    // Osapanga window.location = 'index.html' mwachangu
    // Dikirani kaye
    window.location.href = 'admin.html' // kapena index.html
  }
})