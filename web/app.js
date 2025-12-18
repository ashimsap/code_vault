document.addEventListener('DOMContentLoaded', () => {
    // ... (DOM elements are the same)
    const mainView = document.getElementById('main-view');
    const detailView = document.getElementById('detail-view');
    const snippetsGrid = document.getElementById('snippets-grid');
    const fab = document.getElementById('fab');

    let snippets = [];
    let currentSnippet = null;
    let saveDebounceTimer;
    let keepAliveTimer;

    // ... (main, checkStatus, startKeepAlive, handleRouting are the same)
    const main = async () => {
        try {
            const status = await checkStatus();
            applyTheme(status);
            startKeepAlive();
            await fetchData();
            handleRouting();
        } catch (error) {
            document.body.innerHTML = `<div class="permission-denied"><h1>Paila Dai Lai Sodh</h1><p>(First, ask for permission from the host app)</p></div>`;
        }
    };

    const checkStatus = async () => {
        const response = await fetch('/status');
        if (!response.ok) throw new Error('Permission Denied');
        return response.json();
    };

    const startKeepAlive = () => {
        keepAliveTimer = setInterval(checkStatus, 15000);
    };

    const handleRouting = () => {
        const hash = window.location.hash;
        if (hash.startsWith('#snippet/')) {
            const id = hash.substring(9);
            if (id === 'new') {
                openDetailView(null); 
            } else {
                const snippet = snippets.find(s => s.id === parseInt(id));
                snippet ? openDetailView(snippet) : showMainView();
            }
        } else {
            showMainView();
        }
    };

    const fetchData = async () => {
        try {
            const snippetsRes = await fetch('/api/snippets');
            if (!snippetsRes.ok) throw new Error('Failed to fetch snippets');
            snippets = await snippetsRes.json();
            renderSnippetsGrid();
        } catch (error) {
            console.error('Error fetching data:', error);
        }
    };

    const renderSnippetsGrid = () => {
        snippetsGrid.innerHTML = snippets.map(snippet => {
            const mediaContent = snippet.firstMediaUrl
                ? `<img src="${snippet.firstMediaUrl}" alt="Snippet Media">`
                : `<pre><code>${escapeHtml(snippet.codeContent)}</code></pre>`;
            return `<div class="snippet-card" data-id="${snippet.id}">${mediaContent}</div>`;
        }).join('');
    };

    const openDetailView = (snippet) => {
        currentSnippet = snippet || { description: 'New Snippet', fullDescription: '', codeContent: '', mediaPaths: [] };
        const mediaContent = currentSnippet.firstMediaUrl 
            ? `<img src="${currentSnippet.firstMediaUrl}" alt="Snippet Media">`
            : 'Click to Add Media';

        detailView.innerHTML = `
            <div class="detail-header"><button class="back-button">&larr;</button></div>
            <div class="detail-body">
                <input type="text" id="detail-title" value="${escapeHtml(currentSnippet.description)}">
                <textarea id="detail-description" placeholder="Description...">${escapeHtml(currentSnippet.fullDescription || '')}</textarea>
                <label id="media-upload-label" for="media-upload" class="detail-media-box">${mediaContent}</label>
                <input type="file" id="media-upload" style="display:none;" accept="image/*">
                <div class="code-editor-wrapper">
                    <div id="line-numbers" class="line-numbers">1</div>
                    <textarea id="detail-code" class="code-editor" placeholder="Code..." spellcheck="false">${escapeHtml(currentSnippet.codeContent || '')}</textarea>
                </div>
            </div>
        `;
        mainView.style.display = 'none';
        detailView.style.display = 'flex';

        const codeEditor = document.getElementById('detail-code');
        const lineNumbers = document.getElementById('line-numbers');
        
        const syncScroll = () => { lineNumbers.scrollTop = codeEditor.scrollTop; };
        const updateLineNumbers = () => {
            const lines = codeEditor.value.split('\n').length || 1;
            lineNumbers.innerHTML = Array.from({length: lines}, (_, i) => i + 1).join('\n');
            syncScroll();
        };
        
        codeEditor.addEventListener('input', updateLineNumbers);
        codeEditor.addEventListener('scroll', syncScroll);
        updateLineNumbers();

        document.querySelector('.back-button').addEventListener('click', () => window.history.back());
        ['detail-title', 'detail-description', 'detail-code'].forEach(id => {
            document.getElementById(id).addEventListener('input', handleAutoSave);
        });
        document.getElementById('media-upload').addEventListener('change', uploadMedia);
    };

    const showMainView = async () => {
        if (currentSnippet && (currentSnippet.description || currentSnippet.fullDescription || currentSnippet.codeContent)) {
            await saveSnippet();
        }
        currentSnippet = null;

        detailView.style.display = 'none';
        mainView.style.display = 'block';
        if (window.location.hash) window.history.pushState("", document.title, window.location.pathname + window.location.search);
        fetchData();
    };

    // ... (saveSnippet, uploadMedia, applyTheme, escapeHtml, and other event listeners are the same)
    const handleAutoSave = () => {
        clearTimeout(saveDebounceTimer);
        saveDebounceTimer = setTimeout(saveSnippet, 1500);
    };

    const saveSnippet = async () => {
        if (!currentSnippet) return;
        const isCreating = !currentSnippet.id;
        const endpoint = isCreating ? '/api/snippets/create' : '/api/snippets/update';
        
        let snippetData = {
            ...currentSnippet,
            description: document.getElementById('detail-title').value,
            fullDescription: document.getElementById('detail-description').value,
            codeContent: document.getElementById('detail-code').value,
            lastModificationDate: new Date().toISOString(),
            categories: (currentSnippet.categories || []).join(','),
        };
        if(isCreating) snippetData.creationDate = new Date().toISOString();

        try {
            const response = await fetch(endpoint, { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(snippetData) });
            if (!response.ok) throw new Error('Save failed!');
            
            if(isCreating) {
                const newSnippet = await response.json();
                history.replaceState(null, '', `#snippet/${newSnippet.id}`);
                await fetchData(); 
                currentSnippet = snippets.find(s => s.id === newSnippet.id);
            }
            console.log(`Snippet ${isCreating ? 'created' : 'auto-saved'}.`);
        } catch (error) {
            console.error('Error saving snippet:', error);
        }
    };

    const uploadMedia = async (event) => {
        const file = event.target.files[0];
        if (!file || !currentSnippet.id) return;

        const formData = new FormData();
        formData.append('media', file);

        try {
            const response = await fetch(`/api/media/upload?snippetId=${currentSnippet.id}`, { method: 'POST', body: formData });
            if (!response.ok) throw new Error('Upload failed!');
            const updatedSnippet = await response.json();
            currentSnippet = updatedSnippet;
            openDetailView(updatedSnippet);
        } catch(error) {
            console.error('Error uploading media:', error);
        }
    };

    const applyTheme = (theme) => {
        document.documentElement.style.setProperty('--accent-color', theme.accentColor);
        document.body.classList.toggle('dark-mode', theme.themeMode === 'dark');
    };

    const escapeHtml = (unsafe) => unsafe ? unsafe.replace(/[&<"']/g, m => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#039;' }[m])) : '';

    snippetsGrid.addEventListener('click', (e) => {
        const card = e.target.closest('.snippet-card');
        if (card) window.location.hash = `#snippet/${card.dataset.id}`;
    });
    
    window.addEventListener('popstate', handleRouting);

    fab.addEventListener('click', () => window.location.hash = '#snippet/new');

    main();
});
