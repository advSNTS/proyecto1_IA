%----- Base de Conocimiento -----

% usuarios
usuario(juan).
usuario(maria).
usuario(pedro).
usuario(laura).

% productos: producto(Id, Categoria)
producto(laptop, tecnologia).
producto(smartphone, tecnologia).
producto(audifonos, tecnologia).
producto(camiseta, ropa).
producto(jeans, ropa).
producto(zapatos, ropa).
producto(libro_ai, libros).
producto(libro_prolog, libros).

% compras: compro(Usuario, Producto)
compro(juan, laptop).
compro(juan, smartphone).
compro(juan, libro_ai).

compro(maria, audifonos).
compro(maria, camiseta).
compro(maria, libro_prolog).

compro(pedro, jeans).
compro(pedro, zapatos).
compro(pedro, libro_ai).

compro(laura, smartphone).
compro(laura, libro_prolog).

% calificaciones: calificacion(Usuario, Producto, Nota)
calificacion(juan, laptop, 5).
calificacion(juan, smartphone, 4).
calificacion(juan, libro_ai, 5).

calificacion(maria, audifonos, 4).
calificacion(maria, camiseta, 3).
calificacion(maria, libro_prolog, 5).

calificacion(pedro, jeans, 4).
calificacion(pedro, zapatos, 2).
calificacion(pedro, libro_ai, 5).

calificacion(laura, smartphone, 5).
calificacion(laura, libro_prolog, 4).
%----- Reglas de recomendación -----

% 1. Recomendar un producto basado en categoría de compras previas de un usuario.
recomendar_uno(Usuario, Producto) :-
    compro(Usuario, P1),
    producto(P1, Categoria),
    producto(Producto, Categoria),
    \+ compro(Usuario, Producto).

% 2. Recomendar lista de productos con calificación alta de usuarios similares.
recomendar_lista(Usuario, Lista) :-
    findall(Prod,
        (calificacion(U2, Prod, Nota), U2 \= Usuario, Nota >= 4,
         compro(Usuario, P1), producto(P1, C), producto(Prod, C),
         \+ compro(Usuario, Prod)),
        ListaSinRepetir),
    list_to_set(ListaSinRepetir, Lista).

% 3. Recomendación recursiva: recomendar productos similares por cadena de categorías.
recomendar_recursivo(Usuario, Producto) :-
    compro(Usuario, P1),
    similar_categoria(P1, Producto),
    \+ compro(Usuario, Producto).

% Definición de similitud recursiva por categoría
similar_categoria(P1, P2) :- producto(P1, C), producto(P2, C), P1 \= P2.
similar_categoria(P1, P3) :- producto(P1, C), producto(P2, C), P1 \= P2, similar_categoria(P2, P3).

% ------------------------------
% 4. Top 10 de ítems gustados por un grupo de usuarios
% ------------------------------

% gusto(Usuario, Producto) -> verdadero si la calificación del usuario al producto es mayor a 3
gusto(U, P) :-
    calificacion(U, P, Nota), Nota > 3.

% Recolectar todos los productos que les han gustado a una lista de usuarios
productos_gustados([], []).
productos_gustados([U|Usuarios], ListaTotal) :-
    findall(P, gusto(U, P), ListaUsuario),
    productos_gustados(Usuarios, ListaResto),
    append(ListaUsuario, ListaResto, ListaTotal).

% Contar ocurrencias de productos y devolver lista de pares (Producto, Conteo)
contar_productos([], []).
contar_productos(Lista, Conteos) :-
    list_to_set(Lista, Unicos),
    findall((P,C),
        (member(P, Unicos), include(=(P), Lista, Sub), length(Sub, C)),
        Conteos).

% Ordenar lista de pares (Producto, Conteo) por Conteo descendente
ordenar_por_conteo(Conteos, Ordenados) :-
    sort(2, @>=, Conteos, Ordenados).

% Obtener Top N productos (aquí Top 10)
top_n_productos(N, Usuarios, TopN) :-
    productos_gustados(Usuarios, Lista),
    contar_productos(Lista, Conteos),
    ordenar_por_conteo(Conteos, Ordenados),
    length(TopN, N),
    append(TopN, _, Ordenados).




