<!DOCTYPE html>
<html lang="es">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta http-equiv="X-UA-Compatible" content="ie=edge">
    <meta name="Description" content="Enter your description here" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/4.6.0/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css">
    <link rel="stylesheet" href="assets/css/style.css">
    <title>Quiz</title>
</head>

<body>
    <div class="container">
        <form action="insertar.jsp" method="post">
            <div class="container my-5" style="max-width: 600px;">
        <div class="card shadow-sm">
            <div class="card-body p-4">
                <h2 class="text-center font-weight-bold mb-4">Formulario de Inventario de Equipos Informaticos</h2>
                
                <form action="insertar.jsp" method="post">
                    
                    <!-- Nombre del equipo -->
                    <div class="form-group">
                        <label for="nombre" class="font-weight-bold">Nombre del equipo:</label>
                        <input type="text" class="form-control" id="nombre" name="nombre" required />
                    </div>

                    <!-- ID con validación por patrón (Pattern) -->
                    <div class="form-group">
                        <label for="idEquipo" class="font-weight-bold">ID del equipo:</label>
                        <input type="text" class="form-control" id="idEquipo" name="idEquipo" 
                               pattern="[A-Za-z0-9]{1,10}" 
                               title="El ID debe ser alfanumérico de 3 a 10 caracteres" 
                               placeholder="Ej: EQ1234" required />
                    </div>

                    <!-- Categoría (Select) -->
                    <div class="form-group">
                        <label for="categoria" class="font-weight-bold">Categoria</label>
                        <select class="form-control" id="categoria" name="categoria" required>
                            <option value="" disabled selected>Seleccione una categoria</option>
                            <option value="Laptop">Laptop</option>
                            <option value="Pc de escritorio">Pc de escritorio</option>
                            <option value="Servidor">Servidor</option>
                            <option value="Impresora">Impresora</option>
                            <option value="Accesorios">Accesorios</option>
                        </select>
                    </div>

                    <!-- Marca -->
                    <div class="form-group">
                        <label for="marca" class="font-weight-bold">Marca</label>
                        <input type="text" class="form-control" id="marca" name="marca" />
                    </div>

                    <!-- Fecha de adquisición y Precio en dos columnas -->
                    <div class="form-row">
                        <div class="form-group col-md-6">
                            <label for="fecha" class="font-weight-bold">Fecha de adquisicion</label>
                            <input type="date" class="form-control" id="fecha" name="fecha" />
                        </div>
                        <div class="form-group col-md-6">
                            <label for="precio" class="font-weight-bold">Precio ($):</label>
                            <input type="number"  min="0" id="precio" name="precio" placeholder="0.00" />
                        </div>
                    </div>

                    <!-- Estado (Select) -->
                    <div class="form-group">
                        <label for="estado" class="font-weight-bold">Estado</label>
                        <select class="form-control" id="estado" name="estado" required>
                            <option value="" disabled selected>Seleccione el estado</option>
                            <option value="Nuevo">Nuevo</option>
                            <option value="Buen estado">Buen estado</option>
                            <option value="En Reparacion">En Reparacion</option>
                            <option value="Obsoleto">Obsoleto</option>
                        </select>
                    </div>

                    <!-- Observaciones -->
                    <div class="form-group">
                        <label for="observaciones" class="font-weight-bold">Observaciones</label>
                        <textarea class="form-control" id="observaciones" name="observaciones" rows="3"></textarea>
                    </div>

                    <button type="submit" class="btn btn-primary btn-block mt-4">Guardar Registro</button>
                </form>
    </div>
   
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jquery/3.5.1/jquery.slim.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.16.1/umd/popper.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/4.6.0/js/bootstrap.min.js"></script>
</body>

</html>
