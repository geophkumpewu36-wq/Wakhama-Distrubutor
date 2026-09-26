// Function yo-check ngati munthu walowa mu system
function checkUserAuth() {
    const rawUser = localStorage.getItem('wakhama_user') || localStorage.getItem('user');
    
    if (!rawUser) {
        // Ngati mulibe login data, bwererani ku login.html
        if (!window.location.pathname.includes('login.html') && !window.location.pathname.includes('index.html')) {
            window.location.href = 'login.html';
        }
        return null;
    }

    try {
        return JSON.parse(rawUser);
    } catch (e) {
        localStorage.removeItem('wakhama_user');
        localStorage.removeItem('user');
        window.location.href = 'login.html';
        return null;
    }
}

// Function yo-Logout
function logoutUser() {
    localStorage.removeItem('wakhama_user');
    localStorage.removeItem('user');
    window.location.href = 'login.html';
}

// Tsimikizirani munthu pa tsamba la artist kapena music
document.addEventListener('DOMContentLoaded', () => {
    const currentPage = window.location.pathname;

    // Ngati muli pa artist.html kapena music.html, tsimikizirani auth
    if (currentPage.includes('artist.html') || currentPage.includes('music.html')) {
        const user = checkUserAuth();
        if (user) {
            const userBadge = document.getElementById('userBadge') || document.getElementById('artistNameDisplay');
            if (userBadge) {
                userBadge.innerText = user.identifier || user.email || user.phone || 'User Account';
            }
        }
    }
});