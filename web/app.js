document.addEventListener('DOMContentLoaded', () => {
    // --- DOM Elements ---
    const mainView = document.getElementById('main-view');
    const detailView = document.getElementById('detail-view');
    const snippetsGrid = document.getElementById('snippets-grid');
    const fab = document.getElementById('fab');

    let snippets = [];
    let saveDebounceTimer;

    // --- Main App Logic ---

    // Fetches initial data and sets up the view based on the URL
    const main = async () => {
        await fetchData();
        handleRouting();
    };

    // Renders the correct view based on the URL hash
    const handleRouting = () => {
        const hash = window.location.hash;
        if (hash.startsWith('#snippet/')) {
            const snippetId = parseInt(hash.substring(9));
            const snippet = snippets.find(s => s.id === snippetId);
            if (snippet) {
                openDetailView(snippet);
            } else {
                showMainView(); // Snippet not found, show main grid
            }
        } else {
            showMainView();
        }
    };

    // --- Data Fetching ---
    const fetchData = async () => {
        try {
            const [statusRes, snippetsRes] = await Promise.all([fetch('/status'), fetch('/api/snippets')]);
            if (!statusRes.ok || !snippetsRes.ok) throw new Error('Failed to fetch data');

            const status = await statusRes.json();
            snippets = await snippetsRes.json();
            
            applyTheme(status);
            renderSnippetsGrid();
        } catch (error) {
            console.error('Error fetching data:', error);
        }
    };

    // --- View Rendering ---
    const renderSnippetsGrid = () => {
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
                <button class="back-button">&larr;</button>
                <input type="text" class="detail-header-title" id="detail-title" value="${escapeHtml(snippet.description)}">
            </div>
            <div class="detail-body">
                <div class="detail-meta-section">
                    <textarea id="detail-description" placeholder="Description...">${escapeHtml(snippet.fullDescription || '')}</textarea>
                    <div class="detail-media-box">${mediaContent}</div>
                </div>
                <textarea id="detail-code" class="code-editor" placeholder="Code...">${escapeHtml(snippet.codeContent || '')}</textarea>
            </div>
        `;
        mainView.style.display = 'none';
        detailView.style.display = 'flex';

        // Add event listeners for the new elements
        document.querySelector('.back-button').addEventListener('click', () => window.history.back());
        ['detail-title', 'detail-description', 'detail-code'].forEach(id => {
            document.getElementById(id).addEventListener('input', handleAutoSave);
        });
    };

    const showMainView = () => {
        detailView.style.display = 'none';
        mainView.style.display = 'block';
        window.location.hash = '';
    };

    // --- Actions ---
    const handleAutoSave = () => {
        clearTimeout(saveDebounceTimer);
        saveDebounceTimer = setTimeout(saveSnippet, 1500);
    };

    const saveSnippet = async () => {
        const updatedSnippet = {
            ...currentSnippet,
            description: document.getElementById('detail-title').value,
            fullDescription: document.getElementById('detail-description').value,
            codeContent: document.getElementById('detail-code').value,
            lastModificationDate: new Date().toISOString(),
            categories: (currentSnippet.categories || []).join(','),
        };

        try {
            await fetch('/api/snippets/update', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(updatedSnippet),
            });
            console.log('Snippet auto-saved.');
        } catch (error) {
            console.error('Error auto-saving snippet:', error);
        }
    };

    const applyTheme = (theme) => {
        document.documentElement.style.setProperty('--accent-color', theme.accentColor);
        document.body.classList.toggle('dark-mode', theme.themeMode === 'dark');
    };

    const escapeHtml = (unsafe) => unsafe ? unsafe.replace(/[&<"']/g, m => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#039;' }[m])) : '';

    // --- Event Listeners ---
    snippetsGrid.addEventListener('click', (e) => {
        const card = e.target.closest('.snippet-card');
        if (card) {
            const snippetId = parseInt(card.dataset.id);
            window.location.hash = `#snippet/${snippetId}`;
        }
    });
    
    window.addEventListener('popstate', handleRouting);

    fab.addEventListener('click', () => { /* TODO: Implement create view */ });

    // --- Initial Load ---
    main();
});
