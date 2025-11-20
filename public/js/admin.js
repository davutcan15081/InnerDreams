// Admin Panel JavaScript
class AdminPanel {
    constructor() {
        this.apiBaseUrl = '/api';
        this.token = localStorage.getItem('adminToken');
        this.currentSection = 'dashboard';
        this.currentPage = 1;
        this.currentLimit = 10;
        this.init();
    }

    init() {
        this.setupEventListeners();
        this.checkAuth();
    }

    setupEventListeners() {
        // Login form
        document.getElementById('loginForm').addEventListener('submit', (e) => {
            e.preventDefault();
            this.handleLogin();
        });

        // Logout button
        document.getElementById('logoutBtn').addEventListener('click', () => {
            this.handleLogout();
        });

        // Sidebar navigation
        document.querySelectorAll('[data-section]').forEach(link => {
            link.addEventListener('click', (e) => {
                e.preventDefault();
                const section = e.target.getAttribute('data-section');
                this.navigateToSection(section);
            });
        });

        // Profile button
        document.getElementById('profileBtn').addEventListener('click', () => {
            this.showProfileModal();
        });
    }

    checkAuth() {
        if (this.token) {
            this.verifyToken();
        } else {
            this.showLoginScreen();
        }
    }

    async verifyToken() {
        try {
            const response = await this.apiCall('/auth/verify', 'GET');
            if (response.success) {
                this.showAdminPanel();
                this.loadDashboard();
            } else {
                this.showLoginScreen();
            }
        } catch (error) {
            console.error('Token verification failed:', error);
            this.showLoginScreen();
        }
    }

    async handleLogin() {
        const email = document.getElementById('email').value;
        const password = document.getElementById('password').value;
        const submitBtn = document.querySelector('#loginForm button[type="submit"]');
        const loading = submitBtn.querySelector('.loading');
        const alert = document.getElementById('loginAlert');

        // Show loading
        loading.classList.add('show');
        submitBtn.disabled = true;
        alert.style.display = 'none';

        try {
            const response = await this.apiCall('/auth/login', 'POST', {
                email,
                password
            });

            if (response.success) {
                this.token = response.data.token;
                localStorage.setItem('adminToken', this.token);
                this.showAdminPanel();
                this.loadDashboard();
            } else {
                this.showAlert(alert, response.message, 'danger');
            }
        } catch (error) {
            console.error('Login error:', error);
            this.showAlert(alert, 'Giriş yapılırken bir hata oluştu', 'danger');
        } finally {
            loading.classList.remove('show');
            submitBtn.disabled = false;
        }
    }

    handleLogout() {
        localStorage.removeItem('adminToken');
        this.token = null;
        this.showLoginScreen();
    }

    showLoginScreen() {
        document.getElementById('loginScreen').style.display = 'block';
        document.getElementById('adminPanel').style.display = 'none';
    }

    showAdminPanel() {
        document.getElementById('loginScreen').style.display = 'none';
        document.getElementById('adminPanel').style.display = 'block';
    }

    navigateToSection(section) {
        // Update active nav link
        document.querySelectorAll('.nav-link').forEach(link => {
            link.classList.remove('active');
        });
        document.querySelector(`[data-section="${section}"]`).classList.add('active');

        // Update page title
        const titles = {
            dashboard: 'Dashboard',
            users: 'Kullanıcılar',
            education: 'Eğitimler',
            authors: 'Yazarlar',
            experts: 'Uzmanlar',
            sessions: 'Seanslar',
            appointments: 'Randevular',
            books: 'Kitaplar',
            content: 'İçerikler',
            admins: 'Adminler'
        };
        document.getElementById('pageTitle').textContent = titles[section];

        this.currentSection = section;
        this.loadSectionContent(section);
    }

    async loadSectionContent(section) {
        const contentDiv = document.getElementById('dynamicContent');
        contentDiv.innerHTML = '<div class="text-center"><div class="spinner-border text-primary" role="status"></div></div>';

        try {
            switch (section) {
                case 'dashboard':
                    await this.loadDashboard();
                    break;
                case 'users':
                    await this.loadUsers();
                    break;
                case 'education':
                    await this.loadEducation();
                    break;
                case 'authors':
                    await this.loadAuthors();
                    break;
                case 'experts':
                    await this.loadExperts();
                    break;
                case 'sessions':
                    await this.loadSessions();
                    break;
                case 'appointments':
                    await this.loadAppointments();
                    break;
                case 'books':
                    await this.loadBooks();
                    break;
                case 'content':
                    await this.loadContent();
                    break;
                case 'admins':
                    await this.loadAdmins();
                    break;
            }
        } catch (error) {
            console.error(`Error loading ${section}:`, error);
            contentDiv.innerHTML = '<div class="alert alert-danger">İçerik yüklenirken bir hata oluştu</div>';
        }
    }

    async loadDashboard() {
        try {
            // Load dashboard stats
            const [usersRes, educationRes, sessionsRes, booksRes] = await Promise.all([
                this.apiCall('/users/stats/overview', 'GET'),
                this.apiCall('/education/stats/overview', 'GET'),
                this.apiCall('/sessions/stats/overview', 'GET'),
                this.apiCall('/books/stats/overview', 'GET')
            ]);

            // Update stats
            document.getElementById('totalUsers').textContent = usersRes.data?.totalUsers || 0;
            document.getElementById('totalEducations').textContent = educationRes.data?.totalEducations || 0;
            document.getElementById('totalSessions').textContent = sessionsRes.data?.totalSessions || 0;
            document.getElementById('totalBooks').textContent = booksRes.data?.totalBooks || 0;

            // Load recent activities
            this.loadRecentActivities();
        } catch (error) {
            console.error('Dashboard load error:', error);
        }
    }

    async loadRecentActivities() {
        const activitiesDiv = document.getElementById('recentActivities');
        activitiesDiv.innerHTML = '<p class="text-muted">Son aktiviteler yükleniyor...</p>';

        try {
            // This would be implemented based on your activity tracking system
            const activities = [
                { text: 'Yeni kullanıcı kaydı: Ahmet Yılmaz', time: '2 saat önce', type: 'user' },
                { text: 'Eğitim eklendi: Rüya Analizi Temelleri', time: '4 saat önce', type: 'education' },
                { text: 'Randevu oluşturuldu: Dr. Mehmet Kaya', time: '6 saat önce', type: 'appointment' },
                { text: 'Kitap yüklendi: Rüyaların Dili', time: '1 gün önce', type: 'book' }
            ];

            let html = '';
            activities.forEach(activity => {
                const icon = this.getActivityIcon(activity.type);
                html += `
                    <div class="d-flex align-items-center mb-2">
                        <i class="${icon} me-2 text-primary"></i>
                        <div class="flex-grow-1">
                            <small class="text-muted">${activity.text}</small>
                            <br>
                            <small class="text-muted">${activity.time}</small>
                        </div>
                    </div>
                `;
            });

            activitiesDiv.innerHTML = html;
        } catch (error) {
            activitiesDiv.innerHTML = '<p class="text-muted">Aktiviteler yüklenemedi</p>';
        }
    }

    getActivityIcon(type) {
        const icons = {
            user: 'fas fa-user-plus',
            education: 'fas fa-graduation-cap',
            appointment: 'fas fa-calendar-plus',
            book: 'fas fa-book',
            content: 'fas fa-file-alt'
        };
        return icons[type] || 'fas fa-circle';
    }

    async loadUsers() {
        const contentDiv = document.getElementById('dynamicContent');
        
        try {
            const response = await this.apiCall('/users', 'GET', null, {
                page: this.currentPage,
                limit: this.currentLimit
            });

            if (response.success) {
                this.renderTable('users', response.data.users, [
                    { key: 'fullName', label: 'Ad Soyad' },
                    { key: 'email', label: 'Email' },
                    { key: 'subscriptionStatus', label: 'Abonelik' },
                    { key: 'dreamCount', label: 'Rüya Sayısı' },
                    { key: 'createdAt', label: 'Kayıt Tarihi', type: 'date' }
                ], response.data.pagination);
            } else {
                contentDiv.innerHTML = '<div class="alert alert-danger">Kullanıcılar yüklenemedi</div>';
            }
        } catch (error) {
            contentDiv.innerHTML = '<div class="alert alert-danger">Kullanıcılar yüklenirken bir hata oluştu</div>';
        }
    }

    async loadEducation() {
        const contentDiv = document.getElementById('dynamicContent');
        
        try {
            const response = await this.apiCall('/education', 'GET', null, {
                page: this.currentPage,
                limit: this.currentLimit
            });

            if (response.success) {
                this.renderTable('education', response.data.educations, [
                    { key: 'title', label: 'Başlık' },
                    { key: 'category', label: 'Kategori' },
                    { key: 'level', label: 'Seviye' },
                    { key: 'duration', label: 'Süre (dk)' },
                    { key: 'views', label: 'Görüntülenme' },
                    { key: 'isPublished', label: 'Yayında', type: 'boolean' }
                ], response.data.pagination);
            } else {
                contentDiv.innerHTML = '<div class="alert alert-danger">Eğitimler yüklenemedi</div>';
            }
        } catch (error) {
            contentDiv.innerHTML = '<div class="alert alert-danger">Eğitimler yüklenirken bir hata oluştu</div>';
        }
    }

    async loadAuthors() {
        const contentDiv = document.getElementById('dynamicContent');
        
        try {
            const response = await this.apiCall('/authors', 'GET', null, {
                page: this.currentPage,
                limit: this.currentLimit
            });

            if (response.success) {
                this.renderTable('authors', response.data.authors, [
                    { key: 'fullName', label: 'Ad Soyad' },
                    { key: 'email', label: 'Email' },
                    { key: 'specialization', label: 'Uzmanlık', type: 'array' },
                    { key: 'educationCount', label: 'Eğitim Sayısı' },
                    { key: 'isVerified', label: 'Doğrulanmış', type: 'boolean' }
                ], response.data.pagination);
            } else {
                contentDiv.innerHTML = '<div class="alert alert-danger">Yazarlar yüklenemedi</div>';
            }
        } catch (error) {
            contentDiv.innerHTML = '<div class="alert alert-danger">Yazarlar yüklenirken bir hata oluştu</div>';
        }
    }

    async loadExperts() {
        const contentDiv = document.getElementById('dynamicContent');
        
        try {
            const response = await this.apiCall('/experts', 'GET', null, {
                page: this.currentPage,
                limit: this.currentLimit
            });

            if (response.success) {
                this.renderTable('experts', response.data.experts, [
                    { key: 'fullName', label: 'Ad Soyad' },
                    { key: 'email', label: 'Email' },
                    { key: 'specialization', label: 'Uzmanlık', type: 'array' },
                    { key: 'totalSessions', label: 'Toplam Seans' },
                    { key: 'isVerified', label: 'Doğrulanmış', type: 'boolean' }
                ], response.data.pagination);
            } else {
                contentDiv.innerHTML = '<div class="alert alert-danger">Uzmanlar yüklenemedi</div>';
            }
        } catch (error) {
            contentDiv.innerHTML = '<div class="alert alert-danger">Uzmanlar yüklenirken bir hata oluştu</div>';
        }
    }

    async loadSessions() {
        const contentDiv = document.getElementById('dynamicContent');
        
        try {
            const response = await this.apiCall('/sessions', 'GET', null, {
                page: this.currentPage,
                limit: this.currentLimit
            });

            if (response.success) {
                this.renderTable('sessions', response.data.sessions, [
                    { key: 'title', label: 'Başlık' },
                    { key: 'type', label: 'Tür' },
                    { key: 'category', label: 'Kategori' },
                    { key: 'price', label: 'Fiyat' },
                    { key: 'bookings', label: 'Rezervasyon' },
                    { key: 'isPublished', label: 'Yayında', type: 'boolean' }
                ], response.data.pagination);
            } else {
                contentDiv.innerHTML = '<div class="alert alert-danger">Seanslar yüklenemedi</div>';
            }
        } catch (error) {
            contentDiv.innerHTML = '<div class="alert alert-danger">Seanslar yüklenirken bir hata oluştu</div>';
        }
    }

    async loadAppointments() {
        const contentDiv = document.getElementById('dynamicContent');
        
        try {
            const response = await this.apiCall('/appointments', 'GET', null, {
                page: this.currentPage,
                limit: this.currentLimit
            });

            if (response.success) {
                this.renderTable('appointments', response.data.appointments, [
                    { key: 'appointmentDate', label: 'Tarih', type: 'datetime' },
                    { key: 'user', label: 'Kullanıcı', type: 'object', objectKey: 'fullName' },
                    { key: 'expert', label: 'Uzman', type: 'object', objectKey: 'fullName' },
                    { key: 'status', label: 'Durum' },
                    { key: 'paymentStatus', label: 'Ödeme Durumu' }
                ], response.data.pagination);
            } else {
                contentDiv.innerHTML = '<div class="alert alert-danger">Randevular yüklenemedi</div>';
            }
        } catch (error) {
            contentDiv.innerHTML = '<div class="alert alert-danger">Randevular yüklenirken bir hata oluştu</div>';
        }
    }

    async loadBooks() {
        const contentDiv = document.getElementById('dynamicContent');
        
        try {
            const response = await this.apiCall('/books', 'GET', null, {
                page: this.currentPage,
                limit: this.currentLimit
            });

            if (response.success) {
                this.renderTable('books', response.data.books, [
                    { key: 'title', label: 'Başlık' },
                    { key: 'author', label: 'Yazar' },
                    { key: 'category', label: 'Kategori' },
                    { key: 'price', label: 'Fiyat' },
                    { key: 'downloads', label: 'İndirme' },
                    { key: 'isPublished', label: 'Yayında', type: 'boolean' }
                ], response.data.pagination);
            } else {
                contentDiv.innerHTML = '<div class="alert alert-danger">Kitaplar yüklenemedi</div>';
            }
        } catch (error) {
            contentDiv.innerHTML = '<div class="alert alert-danger">Kitaplar yüklenirken bir hata oluştu</div>';
        }
    }

    async loadContent() {
        const contentDiv = document.getElementById('dynamicContent');
        
        try {
            const response = await this.apiCall('/content', 'GET', null, {
                page: this.currentPage,
                limit: this.currentLimit
            });

            if (response.success) {
                this.renderTable('content', response.data.content, [
                    { key: 'title', label: 'Başlık' },
                    { key: 'type', label: 'Tür' },
                    { key: 'category', label: 'Kategori' },
                    { key: 'views', label: 'Görüntülenme' },
                    { key: 'isPublished', label: 'Yayında', type: 'boolean' },
                    { key: 'publishedAt', label: 'Yayın Tarihi', type: 'date' }
                ], response.data.pagination);
            } else {
                contentDiv.innerHTML = '<div class="alert alert-danger">İçerikler yüklenemedi</div>';
            }
        } catch (error) {
            contentDiv.innerHTML = '<div class="alert alert-danger">İçerikler yüklenirken bir hata oluştu</div>';
        }
    }

    async loadAdmins() {
        const contentDiv = document.getElementById('dynamicContent');
        
        try {
            const response = await this.apiCall('/admin', 'GET', null, {
                page: this.currentPage,
                limit: this.currentLimit
            });

            if (response.success) {
                this.renderTable('admins', response.data.admins, [
                    { key: 'fullName', label: 'Ad Soyad' },
                    { key: 'email', label: 'Email' },
                    { key: 'role', label: 'Rol' },
                    { key: 'isActive', label: 'Aktif', type: 'boolean' },
                    { key: 'lastLogin', label: 'Son Giriş', type: 'date' }
                ], response.data.pagination);
            } else {
                contentDiv.innerHTML = '<div class="alert alert-danger">Adminler yüklenemedi</div>';
            }
        } catch (error) {
            contentDiv.innerHTML = '<div class="alert alert-danger">Adminler yüklenirken bir hata oluştu</div>';
        }
    }

    renderTable(section, data, columns, pagination) {
        const contentDiv = document.getElementById('dynamicContent');
        
        let html = `
            <div class="d-flex justify-content-between align-items-center mb-3">
                <h4>${this.getSectionTitle(section)}</h4>
                <button class="btn btn-primary" onclick="adminPanel.showCreateModal('${section}')">
                    <i class="fas fa-plus me-1"></i>
                    Yeni Ekle
                </button>
            </div>
            
            <div class="card">
                <div class="card-body">
                    <div class="table-responsive">
                        <table class="table table-dark table-hover">
                            <thead>
                                <tr>
                                    ${columns.map(col => `<th>${col.label}</th>`).join('')}
                                    <th>İşlemler</th>
                                </tr>
                            </thead>
                            <tbody>
        `;

        data.forEach(item => {
            html += '<tr>';
            columns.forEach(col => {
                let value = this.getColumnValue(item, col);
                html += `<td>${value}</td>`;
            });
            html += `
                <td>
                    <button class="btn btn-sm btn-outline-primary me-1" onclick="adminPanel.editItem('${section}', '${item._id}')">
                        <i class="fas fa-edit"></i>
                    </button>
                    <button class="btn btn-sm btn-outline-danger" onclick="adminPanel.deleteItem('${section}', '${item._id}')">
                        <i class="fas fa-trash"></i>
                    </button>
                </td>
            </tr>`;
        });

        html += `
                            </tbody>
                        </table>
                    </div>
                    
                    ${this.renderPagination(pagination)}
                </div>
            </div>
        `;

        contentDiv.innerHTML = html;
    }

    getColumnValue(item, column) {
        let value = item[column.key];
        
        if (column.type === 'date') {
            return value ? new Date(value).toLocaleDateString('tr-TR') : '-';
        } else if (column.type === 'datetime') {
            return value ? new Date(value).toLocaleString('tr-TR') : '-';
        } else if (column.type === 'boolean') {
            return value ? '<span class="badge bg-success">Evet</span>' : '<span class="badge bg-danger">Hayır</span>';
        } else if (column.type === 'array') {
            return Array.isArray(value) ? value.join(', ') : '-';
        } else if (column.type === 'object' && column.objectKey) {
            return value && value[column.objectKey] ? value[column.objectKey] : '-';
        }
        
        return value || '-';
    }

    getSectionTitle(section) {
        const titles = {
            users: 'Kullanıcılar',
            education: 'Eğitimler',
            authors: 'Yazarlar',
            experts: 'Uzmanlar',
            sessions: 'Seanslar',
            appointments: 'Randevular',
            books: 'Kitaplar',
            content: 'İçerikler',
            admins: 'Adminler'
        };
        return titles[section] || section;
    }

    renderPagination(pagination) {
        if (!pagination || pagination.pages <= 1) return '';

        let html = '<nav><ul class="pagination justify-content-center">';
        
        // Previous button
        if (pagination.current > 1) {
            html += `<li class="page-item"><a class="page-link" href="#" onclick="adminPanel.changePage(${pagination.current - 1})">Önceki</a></li>`;
        }
        
        // Page numbers
        for (let i = 1; i <= pagination.pages; i++) {
            const activeClass = i === pagination.current ? 'active' : '';
            html += `<li class="page-item ${activeClass}"><a class="page-link" href="#" onclick="adminPanel.changePage(${i})">${i}</a></li>`;
        }
        
        // Next button
        if (pagination.current < pagination.pages) {
            html += `<li class="page-item"><a class="page-link" href="#" onclick="adminPanel.changePage(${pagination.current + 1})">Sonraki</a></li>`;
        }
        
        html += '</ul></nav>';
        return html;
    }

    changePage(page) {
        this.currentPage = page;
        this.loadSectionContent(this.currentSection);
    }

    showCreateModal(section) {
        // This would be implemented based on the specific section
        const modal = new bootstrap.Modal(document.getElementById('createModal'));
        document.getElementById('createModalTitle').textContent = `Yeni ${this.getSectionTitle(section)}`;
        modal.show();
    }

    editItem(section, id) {
        // This would be implemented based on the specific section
        console.log(`Edit ${section} with id: ${id}`);
    }

    deleteItem(section, id) {
        if (confirm('Bu kaydı silmek istediğinizden emin misiniz?')) {
            // This would be implemented based on the specific section
            console.log(`Delete ${section} with id: ${id}`);
        }
    }

    showProfileModal() {
        // This would show the admin profile modal
        console.log('Show profile modal');
    }

    showAlert(element, message, type) {
        element.className = `alert alert-${type}`;
        element.textContent = message;
        element.style.display = 'block';
    }

    async apiCall(endpoint, method = 'GET', data = null, params = null) {
        const url = new URL(this.apiBaseUrl + endpoint, window.location.origin);
        
        if (params) {
            Object.keys(params).forEach(key => {
                if (params[key] !== null && params[key] !== undefined) {
                    url.searchParams.append(key, params[key]);
                }
            });
        }

        const options = {
            method,
            headers: {
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${this.token}`
            }
        };

        if (data && method !== 'GET') {
            options.body = JSON.stringify(data);
        }

        const response = await fetch(url, options);
        return await response.json();
    }
}

// Initialize admin panel when DOM is loaded
document.addEventListener('DOMContentLoaded', () => {
    window.adminPanel = new AdminPanel();
});
