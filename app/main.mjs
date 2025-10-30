import confetti from 'canvas-confetti';

// Configuration for confetti animations
const confettiConfig = {
    particleCount: 100,
    spread: 70,
    origin: { y: 0.6 }
};

// Function to trigger confetti animation
function celebrate() {
    confetti(confettiConfig);
}

// Function to create and display celebration message
function showCelebrationMessage() {
    const messageDiv = document.createElement('div');
    messageDiv.innerHTML = `
        <h1>🎉 Continuous Deployment Success! 🎉</h1>
        <p>Your application has been successfully deployed using GitHub Actions!</p>
        <p>This demonstrates the power of continuous deployment the GitHub way.</p>
        <button id="celebrateBtn">Celebrate! 🎊</button>
    `;
    messageDiv.style.cssText = `
        text-align: center;
        padding: 2rem;
        margin: 2rem auto;
        max-width: 600px;
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        color: white;
        border-radius: 10px;
        box-shadow: 0 10px 30px rgba(0,0,0,0.3);
        font-family: 'Arial', sans-serif;
    `;
    
    document.body.appendChild(messageDiv);
    
    // Add event listener to celebration button
    document.getElementById('celebrateBtn').addEventListener('click', celebrate);
    
    // Auto-celebrate on load
    setTimeout(celebrate, 500);
}

// Initialize the application when DOM is loaded
document.addEventListener('DOMContentLoaded', showCelebrationMessage);

// Export for potential external use
export { celebrate, showCelebrationMessage };