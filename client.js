// Function yo-check munthu ngati walowa
function getLoggedInUser() {
    const userStr = localStorage.getItem('user') || localStorage.getItem('wakhama_user');
    if (!userStr) return null;
    try {
        return JSON.parse(userStr);
    } catch (e) {
        return null;
    }
}

// Kukonza tsamba lokha mukalowa
document.addEventListener('DOMContentLoaded', () => {
    const currentUser = getLoggedInUser();
    const currentPath = window.location.pathname;

    // Ngati muli pa tsamba la login kapena index, musamukankhire kulikonse
    if (currentPath.includes('login.html') || currentPath.includes('index.html')) {
        return;
    }

    // Ngati mulibe user ndipo muli pa tsamba la music, upload kapena admin, mutumizeni ku login
    if (!currentUser) {
        window.location.href = 'login.html';
        return;
    }

    // Ngati walowa, onetsani dzina lake
    const userBadge = document.getElementById('userBadge') || document.getElementById('artistNameDisplay');
    if (userBadge) {
        userBadge.innerText = "Logged in: " + (currentUser.identifier || currentUser.email || currentUser.phone || 'User');
    }
});

function logoutUser() {
    localStorage.clear();
    window.location.href = 'login.html';
}