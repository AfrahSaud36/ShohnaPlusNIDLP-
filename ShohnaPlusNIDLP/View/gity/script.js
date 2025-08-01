document.addEventListener('DOMContentLoaded', function() {
    const githubImage = document.getElementById('github-image');
    const playBtn = document.getElementById('play-btn');
    const pauseBtn = document.getElementById('pause-btn');
    const resetBtn = document.getElementById('reset-btn');
    const floatingIcons = document.querySelectorAll('.floating-icon');
    const githubCard = document.querySelector('.github-card');

    // Play animation
    playBtn.addEventListener('click', function() {
        githubImage.classList.remove('paused', 'reset');
        floatingIcons.forEach(icon => icon.classList.remove('paused', 'reset'));
        githubCard.classList.remove('paused', 'reset');
        
        // Add some interactive effects
        githubImage.style.animationPlayState = 'running';
        floatingIcons.forEach(icon => {
            icon.style.animationPlayState = 'running';
        });
        
        // Add a pulse effect
        githubCard.style.animation = 'pulse 2s ease-in-out';
    });

    // Pause animation
    pauseBtn.addEventListener('click', function() {
        githubImage.classList.add('paused');
        floatingIcons.forEach(icon => icon.classList.add('paused'));
        githubCard.classList.add('paused');
        
        githubImage.style.animationPlayState = 'paused';
        floatingIcons.forEach(icon => {
            icon.style.animationPlayState = 'paused';
        });
    });

    // Reset animation
    resetBtn.addEventListener('click', function() {
        githubImage.classList.add('reset');
        floatingIcons.forEach(icon => icon.classList.add('reset'));
        githubCard.classList.add('reset');
        
        // Reset after a short delay
        setTimeout(() => {
            githubImage.classList.remove('reset');
            floatingIcons.forEach(icon => icon.classList.remove('reset'));
            githubCard.classList.remove('reset');
        }, 100);
    });

    // Mouse movement effect
    document.addEventListener('mousemove', function(e) {
        const mouseX = e.clientX / window.innerWidth;
        const mouseY = e.clientY / window.innerHeight;
        
        // Subtle parallax effect
        githubImage.style.transform = `translateY(${(mouseY - 0.5) * 10}px) rotate(${(mouseX - 0.5) * 2}deg)`;
    });

    // Add click effect on image
    githubImage.addEventListener('click', function() {
        this.style.transform = 'scale(1.1) rotate(5deg)';
        setTimeout(() => {
            this.style.transform = '';
        }, 300);
    });

    // Add hover sound effect (optional)
    githubImage.addEventListener('mouseenter', function() {
        // You can add sound here if needed
        this.style.filter = 'brightness(1.2) contrast(1.1) saturate(1.2)';
    });

    githubImage.addEventListener('mouseleave', function() {
        this.style.filter = '';
    });

    // Add keyboard controls
    document.addEventListener('keydown', function(e) {
        switch(e.key) {
            case ' ':
                e.preventDefault();
                playBtn.click();
                break;
            case 'p':
                pauseBtn.click();
                break;
            case 'r':
                resetBtn.click();
                break;
        }
    });

    // Add touch support for mobile
    let touchStartY = 0;
    githubImage.addEventListener('touchstart', function(e) {
        touchStartY = e.touches[0].clientY;
    });

    githubImage.addEventListener('touchmove', function(e) {
        e.preventDefault();
        const touchY = e.touches[0].clientY;
        const deltaY = touchY - touchStartY;
        
        this.style.transform = `translateY(${deltaY * 0.1}px)`;
    });

    githubImage.addEventListener('touchend', function() {
        this.style.transform = '';
    });

    // Add CSS animation for pulse effect
    const style = document.createElement('style');
    style.textContent = `
        @keyframes pulse {
            0%, 100% { transform: scale(1); }
            50% { transform: scale(1.02); }
        }
        
        .github-card {
            transition: all 0.3s ease;
        }
    `;
    document.head.appendChild(style);
}); 