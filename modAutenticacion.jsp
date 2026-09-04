<style>
        /* Estilos específicos para las ventanas modales de Autenticación */
        .auth-modal .modal-content {
            border: none;
            border-radius: 20px;
            box-shadow: 0 25px 50px -12px rgba(11, 25, 44, 0.25);
            overflow: hidden;
        }

        .auth-header {
            background-color: var(--primary-navy);
            color: #ffffff;
            padding: 2rem 2rem 1.5rem 2rem;
            position: relative;
        }

        .auth-nav-pills {
            background-color: rgba(255, 255, 255, 0.1);
            border-radius: 12px;
            padding: 4px;
        }

        .auth-nav-pills .nav-link {
            color: #a0aec0;
            border-radius: 9px;
            font-weight: 700;
            font-size: 0.9rem;
            transition: all 0.3s ease;
        }

        .auth-nav-pills .nav-link.active {
            background-color: #ffffff;
            color: var(--accent-red) !important;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
        }

        .auth-body {
            padding: 2rem;
            background-color: #ffffff;
        }

        .password-toggle-btn {
            position: absolute;
            right: 15px;
            top: 50%;
            transform: translateY(-50%);
            border: none;
            background: none;
            color: #94a3b8;
            cursor: pointer;
            z-index: 5;
        }
        
        .password-toggle-btn:hover {
            color: var(--primary-navy);
        }

        .social-auth-btn {
            border: 1px solid #e2e8f0;
            border-radius: 10px;
            padding: 10px;
            font-weight: 600;
            font-size: 0.9rem;
            color: #4a5568;
            background: #ffffff;
            transition: all 0.2s ease;
        }

        .social-auth-btn:hover {
            background-color: #f8fafc;
            border-color: #cbd5e1;
        }

        .divider-text {
            display: flex;
            align-items: center;
            text-align: center;
            color: #94a3b8;
            font-size: 0.8rem;
            font-weight: 600;
            margin: 1.5rem 0;
        }

        .divider-text::before,
        .divider-text::after {
            content: '';
            flex: 1;
            border-bottom: 1px solid #e2e8f0;
        }

        .divider-text span {
            padding: 0 10px;
        }
    </style>

    <div class="modal fade auth-modal" id="authModal" tabindex="-1" aria-labelledby="authModalLabel" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content">
                
                <div class="auth-header">
                    <button type="button" class="btn-close btn-close-white position-absolute top-0 end-0 m-3" data-bs-dismiss="modal" aria-label="Cerrar"></button>
                    <div class="text-center mb-3">
                        <h4 class="fw-bold mb-1">Bienvenido a FINCAR</h4>
                        <p class="small text-white-50 mb-0">Gestiona tus consultas, pagos e inmuebles en un solo lugar</p>
                    </div>

                    <ul class="nav nav-pills auth-nav-pills nav-justified" id="authTab" role="tablist">
                        <li class="nav-item" role="presentation">
                            <button class="nav-link active" id="login-tab" data-bs-toggle="pill" data-bs-target="#login-panel" type="button" role="tab" aria-controls="login-panel" aria-selected="true">
                                <i class="fa-solid fa-right-to-bracket me-2"></i>Iniciar Sesión
                            </button>
                        </li>
                        <li class="nav-item" role="presentation">
                            <button class="nav-link" id="register-tab" data-bs-toggle="pill" data-bs-target="#register-panel" type="button" role="tab" aria-controls="register-panel" aria-selected="false">
                                <i class="fa-solid fa-user-plus me-2"></i>Registrarse
                            </button>
                        </li>
                    </ul>
                </div>

                <div class="auth-body">
                    <div class="tab-content" id="authTabContent">
                        
                        <div class="tab-pane fade show active" id="login-panel" role="tabpanel" aria-labelledby="login-tab">
                            <form id="loginForm" novalidate>
                                <div class="mb-3">
                                    <label class="form-label small fw-bold text-uppercase text-muted">Correo Electrónico</label>
                                    <div class="input-icon-group">
                                        <i class="fa-solid fa-envelope"></i>
                                        <input type="email" class="form-control" placeholder="ejemplo@correo.com" required>
                                    </div>
                                </div>

                                <div class="mb-2">
                                    <div class="d-flex justify-content-between align-items-center">
                                        <label class="form-label small fw-bold text-uppercase text-muted">Contraseña</label>
                                        <a href="#" class="small text-danger fw-semibold text-decoration-none" data-bs-toggle="modal" data-bs-target="#forgotPasswordModal">¿Olvidaste tu contraseña?</a>
                                    </div>
                                    <div class="input-icon-group">
                                        <i class="fa-solid fa-lock"></i>
                                        <input type="password" class="form-control auth-password" placeholder="••••••••" required>
                                        <button type="button" class="password-toggle-btn" onclick="togglePasswordVisibility(this)">
                                            <i class="fa-solid fa-eye"></i>
                                        </button>
                                    </div>
                                </div>

                                <div class="form-check mb-4 mt-3">
                                    <input class="form-check-input" type="checkbox" id="rememberMe">
                                    <label class="form-check-label small text-muted fw-semibold" for="rememberMe">
                                        Recordar mi sesión en este dispositivo
                                    </label>
                                </div>

                                <button type="submit" class="btn btn-action w-100 fs-6">
                                    Ingresar al Sistema <i class="fa-solid fa-arrow-right-to-bracket ms-2"></i>
                                </button>
                            </form>

                            <div class="divider-text">
                                <span>O ENTRAR CON</span>
                            </div>

                            <div class="d-flex gap-2">
                                <button type="button" class="btn social-auth-btn w-50 d-flex align-items-center justify-content-center gap-2">
                                    <i class="fa-brands fa-google text-danger"></i> Google
                                </button>
                                <button type="button" class="btn social-auth-btn w-50 d-flex align-items-center justify-content-center gap-2">
                                    <i class="fa-brands fa-facebook text-primary"></i> Facebook
                                </button>
                            </div>
                        </div>

                        <div class="tab-pane fade" id="register-panel" role="tabpanel" aria-labelledby="register-tab">
                            <form id="registerForm" novalidate>
                                <div class="mb-3">
                                    <label class="form-label small fw-bold text-uppercase text-muted">Nombre Completo</label>
                                    <div class="input-icon-group">
                                        <i class="fa-solid fa-user"></i>
                                        <input type="text" class="form-control" placeholder="Juan Pérez" required>
                                    </div>
                                </div>

                                <div class="row g-2 mb-3">
                                    <div class="col-md-6">
                                        <label class="form-label small fw-bold text-uppercase text-muted">Teléfono / WhatsApp</label>
                                        <div class="input-icon-group">
                                            <i class="fa-solid fa-phone"></i>
                                            <input type="tel" class="form-control" placeholder="300 000 0000" required>
                                        </div>
                                    </div>
                                    <div class="col-md-6">
                                        <label class="form-label small fw-bold text-uppercase text-muted">Tipo de Usuario</label>
                                        <div class="input-icon-group">
                                            <i class="fa-solid fa-users-gear"></i>
                                            <select class="form-select" required>
                                                <option selected disabled value="">Seleccionar...</option>
                                                <option>Arrendatario</option>
                                                <option>Propietario</option>
                                                <option>Comprador / Inversionista</option>
                                            </select>
                                        </div>
                                    </div>
                                </div>

                                <div class="mb-3">
                                    <label class="form-label small fw-bold text-uppercase text-muted">Correo Electrónico</label>
                                    <div class="input-icon-group">
                                        <i class="fa-solid fa-envelope"></i>
                                        <input type="email" class="form-control" placeholder="ejemplo@correo.com" required>
                                    </div>
                                </div>

                                <div class="mb-3">
                                    <label class="form-label small fw-bold text-uppercase text-muted">Contraseña</label>
                                    <div class="input-icon-group">
                                        <i class="fa-solid fa-lock"></i>
                                        <input type="password" class="form-control auth-password" placeholder="Mínimo 8 caracteres" required>
                                        <button type="button" class="password-toggle-btn" onclick="togglePasswordVisibility(this)">
                                            <i class="fa-solid fa-eye"></i>
                                        </button>
                                    </div>
                                </div>

                                <div class="form-check mb-4">
                                    <input class="form-check-input" type="checkbox" id="termsCheck" required>
                                    <label class="form-check-label small text-muted" for="termsCheck">
                                        Acepto los <a href="#" class="text-danger fw-semibold">Términos del Servicio</a> y la <a href="#" class="text-danger fw-semibold">Política de Tratamiento de Datos</a>.
                                    </label>
                                </div>

                                <button type="submit" class="btn btn-action w-100 fs-6">
                                    Crear Mi Cuenta <i class="fa-solid fa-user-check ms-2"></i>
                                </button>
                            </form>
                        </div>

                    </div>
                </div>

            </div>
        </div>
    </div>

    <div class="modal fade" id="forgotPasswordModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered modal-sm">
            <div class="modal-content border-0 rounded-4 shadow">
                <div class="modal-body p-4 text-center">
                    <div class="icon-box bg-danger bg-opacity-10 text-danger mx-auto mb-3">
                        <i class="fa-solid fa-key"></i>
                    </div>
                    <h5 class="fw-bold mb-2">Restablecer Clave</h5>
                    <p class="small text-muted mb-3">Ingresa tu correo registrado para enviarte un enlace de recuperación.</p>
                    
                    <form>
                        <div class="input-icon-group mb-3">
                            <i class="fa-solid fa-envelope"></i>
                            <input type="email" class="form-control" placeholder="tu@correo.com" required>
                        </div>
                        <button type="submit" class="btn btn-action w-100 btn-sm mb-2">Enviar Enlace</button>
                        <button type="button" class="btn btn-link text-muted btn-sm text-decoration-none" data-bs-toggle="modal" data-bs-target="#authModal">Volver a inicio de sesión</button>
                    </form>
                </div>
            </div>
        </div>
    </div>

    <script>
        // Función para cambiar los botones de la barra superior para que abran el modal
        document.addEventListener('DOMContentLoaded', () => {
            // Vincular enlaces existentes al modal
            const portalBtn = document.querySelector('a[href="#portal"]');
            const consignarBtn = document.querySelector('a[href="#consignar"]');
            
            if (portalBtn) {
                portalBtn.setAttribute('data-bs-toggle', 'modal');
                portalBtn.setAttribute('data-bs-target', '#authModal');
            }
            
            if (consignarBtn) {
                consignarBtn.setAttribute('data-bs-toggle', 'modal');
                consignarBtn.setAttribute('data-bs-target', '#authModal');
            }
        });

        // Alternar la visibilidad de la contraseña
        function togglePasswordVisibility(button) {
            const input = button.parentElement.querySelector('.auth-password');
            const icon = button.querySelector('i');
            
            if (input.type === 'password') {
                input.type = 'text';
                icon.classList.remove('fa-eye');
                icon.classList.add('fa-eye-slash');
            } else {
                input.type = 'password';
                icon.classList.remove('fa-eye-slash');
                icon.classList.add('fa-eye');
            }
        }
    </script>