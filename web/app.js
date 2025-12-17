document.addEventListener('DOMContentLoaded', async () => {
    const statusContainer = document.getElementById('status-container');

    try {
        const response = await fetch('/status');
        if (!response.ok) {
            throw new Error(`HTTP error! status: ${response.status}`);
        }
        const status = await response.json();

        let statusHtml = '';
        if (status.isServerRunning) {
            statusHtml += `<p class="success">Server is running!</p>`;
            if (status.ipAddress) {
                statusHtml += `<p>URL: <a href="http://${status.ipAddress}:${status.port}">http://${status.ipAddress}:${status.port}</a></p>`;
            } else {
                statusHtml += `<p class="error">IP Address not available.</p>`;
            }
        } else {
            statusHtml += `<p class="error">Server is not running.</p>`;
        }

        statusContainer.innerHTML = statusHtml;

    } catch (e) {
        statusContainer.innerHTML = `<p class="error">Failed to fetch status: ${e.message}</p>`;
        console.error('Failed to fetch status:', e);
    }
});
