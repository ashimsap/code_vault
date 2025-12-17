document.addEventListener('DOMContentLoaded', () => {
    const statusContainer = document.getElementById('status-container');
    const snippetsContainer = document.getElementById('snippets-container');
    const addSnippetForm = document.getElementById('add-snippet-form');

    const applyTheme = (theme) => {
        document.documentElement.style.setProperty('--accent-color', theme.accentColor);
        if (theme.themeMode === 'dark') {
            document.body.classList.add('dark-mode');
        } else {
            document.body.classList.remove('dark-mode');
        }
    };

    const fetchStatus = async () => {
        try {
            const response = await fetch('/status');
            if (!response.ok) throw new Error(`HTTP error! status: ${response.status}`);
            const status = await response.json();

            applyTheme(status); // Apply the theme

            let statusHtml = '';
            if (status.isServerRunning) {
                statusHtml += `<p class="success">Server is running!</p>`;
                if (status.ipAddress) {
                    statusHtml += `<p>URL: <a href="http://${status.ipAddress}:${status.port}">http://${status.ipAddress}:${status.port}</a></p>`;
                }
            } else {
                statusHtml += `<p class="error">Server is not running.</p>`;
            }
            statusContainer.innerHTML = statusHtml;
        } catch (e) {
            statusContainer.innerHTML = `<p class="error">Failed to fetch status: ${e.message}</p>`;
        }
    };

    const fetchSnippets = async () => {
        try {
            const response = await fetch('/api/snippets');
            if (!response.ok) throw new Error(`HTTP error! status: ${response.status}`);
            const snippets = await response.json();

            if (snippets.length === 0) {
                snippetsContainer.innerHTML = '<p>No snippets found.</p>';
                return;
            }

            let snippetsHtml = '';
            for (const snippet of snippets) {
                snippetsHtml += `
                    <div class="snippet-card">
                        <h3>${escapeHtml(snippet.description)}</h3>
                        <pre><code>${escapeHtml(snippet.codeContent)}</code></pre>
                    </div>
                `;
            }
            snippetsContainer.innerHTML = snippetsHtml;
        } catch (e) {
            snippetsContainer.innerHTML = `<p class="error">Failed to fetch snippets: ${e.message}</p>`;
        }
    };

    const handleAddSnippet = async (event) => {
        event.preventDefault();
        const description = document.getElementById('description').value;
        const code = document.getElementById('code').value;

        if (!description || !code) return;

        try {
            await fetch('/api/snippets/create', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ description, codeContent: code }),
            });
            addSnippetForm.reset();
            fetchSnippets();
        } catch (e) {
            alert(`Failed to add snippet: ${e.message}`);
        }
    };

    const escapeHtml = (unsafe) => {
        return unsafe
            .replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;")
            .replace(/"/g, "&quot;").replace(/'/g, "&#039;");
    }

    addSnippetForm.addEventListener('submit', handleAddSnippet);

    // Initial data fetch
    fetchStatus();
    fetchSnippets();
});
