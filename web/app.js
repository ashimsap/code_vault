document.addEventListener('DOMContentLoaded', () => {
    // --- DOM Elements ---
    const mainView = document.getElementById('main-view');
    const detailView = document.getElementById('detail-view');
    const snippetsGrid = document.getElementById('snippets-grid');
    const fab = document.getElementById('fab');

    let snippets = [];
    let currentSnippet = null;

    // --- Functions ---
    const applyTheme = (theme) => {
        document.documentElement.style.setProperty('--accent-color', theme.accentColor);
        document.body.classList.toggle('dark-mode', theme.themeMode === 'dark');
    };

    const renderSnippets = () => {
        snippetsGrid.innerHTML = snippets.map(snippet => {
            const mediaContent = snippet.firstMediaUrl
                ? `<img src="${snippet.firstMediaUrl}" alt="Snippet Media">`
                : `<pre><code>${escapeHtml(snippet.codeContent)}</code></pre>`;
            return `
                <div class="snippet-card" data-id="${snippet.id}">
                    <h3>${escapeHtml(snippet.description)}</h3>
                    <div class="media-preview">${mediaContent}</div>
                </div>
            `;
        }).join('');
    };

    const openDetailView = (snippet) => {
        currentSnippet = snippet;
        const mediaContent = snippet.firstMediaUrl 
            ? `<img src="${snippet.firstMediaUrl}" alt="Snippet Media">`
            : 'Add Media';

        detailView.innerHTML = `
            <div class="detail-header">
                <button id="back-button">&larr; Back</button>
                <button id="save-button">Save</button>
            </div>
            <div class="detail-body">
                <input type="text" id="detail-title" value="${escapeHtml(snippet.description)}">
                <div class="detail-side-by-side">
                    <textarea id="detail-description" placeholder="Description...">${escapeHtml(snippet.fullDescription || '')}</textarea>
                    <div class="detail-media-box">${mediaContent}</div>
                </div>
                <textarea id="detail-code" placeholder="Code...">${escapeHtml(snippet.codeContent || '')}</textarea>
            </div>
        `;
        mainView.style.display = 'none';
        detailView.style.display = 'flex';

        // Add event listeners for the new elements
        document.getElementById('back-button').addEventListener('click', closeDetailView);
        document.getElementById('save-button').addEventListener('click', saveSnippet);
    };

    const closeDetailView = () => {
        detailView.style.display = 'none';
        mainView.style.display = 'block';
    };

    const saveSnippet = async () => {
        const updatedSnippet = {
            ...currentSnippet,
            description: document.getElementById('detail-title').value,
            fullDescription: document.getElementById('detail-description').value,
            codeContent: document.getElementById('detail-code').value,
            lastModificationDate: new Date().toISOString(),
        };

        try {
            const response = await fetch('/api/snippets/update', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(updatedSnippet),
            });
            if (!response.ok) throw new Error('Save failed!');
            closeDetailView();
            fetchData(); // Refresh all data
        } catch (error) {
            console.error('Error saving snippet:', error);
            alert('Could not save snippet.');
        }
    };

    const fetchData = async () => {
        try {
            const [statusRes, snippetsRes] = await Promise.all([ fetch('/status'), fetch('/api/snippets') ]);
            if (!statusRes.ok || !snippetsRes.ok) throw new Error('Failed to fetch data');

            const status = await statusRes.json();
            snippets = await snippetsRes.json();
            
            applyTheme(status);
            renderSnippets();
        } catch (error) {
            console.error('Error fetching data:', error);
        }
    };
    
    const escapeHtml = (unsafe) => unsafe.replace(/[&<"']/g, (m) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#039;' }[m]));

    // --- Event Listeners ---
    snippetsGrid.addEventListener('click', (e) => {
        const card = e.target.closest('.snippet-card');
        if (card) {
            const snippetId = parseInt(card.dataset.id);
            const snippet = snippets.find(s => s.id === snippetId);
            if (snippet) openDetailView(snippet);
        }
    });

    fab.addEventListener('click', () => { /* TODO: Implement create view */ });

    // --- Initial Load ---
    fetchData();
});
