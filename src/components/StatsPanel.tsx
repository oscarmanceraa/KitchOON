import { 
  TrendingUp, 
  DollarSign, 
  ShoppingCart, 
  Users, 
  Clock, 
  Package,
  ChefHat,
  Receipt,
  ArrowUp,
  ArrowDown
} from 'lucide-react';
import { Card, CardContent, CardHeader, CardTitle } from './ui/card';
import { 
  BarChart, 
  Bar, 
  LineChart, 
  Line, 
  PieChart, 
  Pie, 
  Cell,
  XAxis, 
  YAxis, 
  CartesianGrid, 
  Tooltip, 
  Legend, 
  ResponsiveContainer 
} from 'recharts';
import type { OrdenCompleta, Producto, Usuario } from '../types/database';
import * as DB from '../lib/mockDatabase';

interface StatsPanelProps {
  ordenes: OrdenCompleta[];
  productos: Producto[];
  usuarios: Usuario[];
}

export function StatsPanel({ ordenes, productos, usuarios }: StatsPanelProps) {
  // Calcular estadísticas generales
  const hoy = new Date();
  hoy.setHours(0, 0, 0, 0);
  
  const ordenesHoy = ordenes.filter(o => {
    if (!o.FechaCreacion) return false;
    const fecha = new Date(o.FechaCreacion);
    fecha.setHours(0, 0, 0, 0);
    return fecha.getTime() === hoy.getTime();
  });

  const ordenesActivas = ordenes.filter(o => 
    o.IdEstado !== 5 && o.IdEstado !== 6 // No completadas ni canceladas
  );

  const ordenesCompletadas = ordenes.filter(o => o.IdEstado === 5);
  const ordenesCanceladas = ordenes.filter(o => o.IdEstado === 6);

  // Calcular ingresos
  const calcularTotal = (orden: OrdenCompleta): number => {
    return orden.Productos?.reduce((total, po) => {
      const precio = po.Producto?.Valor || 0;
      const cantidad = po.Cantidad || 1;
      return total + (precio * cantidad);
    }, 0) || 0;
  };

  const ingresosHoy = ordenesHoy
    .filter(o => o.IdEstado === 5)
    .reduce((sum, o) => sum + calcularTotal(o), 0);

  const ingresosTotales = ordenesCompletadas
    .reduce((sum, o) => sum + calcularTotal(o), 0);

  const promedioOrden = ordenesCompletadas.length > 0 
    ? ingresosTotales / ordenesCompletadas.length 
    : 0;

  // Tiempo promedio de preparación
  const tiempoPromedioPreparacion = ordenesCompletadas.length > 0
    ? Math.round(
        ordenesCompletadas.reduce((acc, orden) => {
          if (!orden.FechaCreacion) return acc;
          const minutos = Math.floor((Date.now() - orden.FechaCreacion.getTime()) / 60000);
          return acc + minutos;
        }, 0) / ordenesCompletadas.length
      )
    : 0;

  // Productos más vendidos
  const productosVendidos: Record<number, { nombre: string; cantidad: number; ingresos: number }> = {};
  
  ordenes.forEach(orden => {
    if (orden.IdEstado === 5) { // Solo órdenes completadas
      orden.Productos?.forEach(po => {
        const id = po.IdProducto;
        const producto = po.Producto;
        if (producto) {
          if (!productosVendidos[id]) {
            productosVendidos[id] = {
              nombre: producto.NombreProducto,
              cantidad: 0,
              ingresos: 0
            };
          }
          productosVendidos[id].cantidad += po.Cantidad || 1;
          productosVendidos[id].ingresos += (producto.Valor || 0) * (po.Cantidad || 1);
        }
      });
    }
  });

  const topProductos = Object.values(productosVendidos)
    .sort((a, b) => b.cantidad - a.cantidad)
    .slice(0, 5);

  // Datos para gráfica de órdenes por día (últimos 7 días)
  const obtenerUltimos7Dias = () => {
    const dias = [];
    for (let i = 6; i >= 0; i--) {
      const fecha = new Date();
      fecha.setDate(fecha.getDate() - i);
      fecha.setHours(0, 0, 0, 0);
      dias.push(fecha);
    }
    return dias;
  };

  const ordenesPorDia = obtenerUltimos7Dias().map(dia => {
    const ordenesDelDia = ordenes.filter(o => {
      if (!o.FechaCreacion) return false;
      const fechaOrden = new Date(o.FechaCreacion);
      fechaOrden.setHours(0, 0, 0, 0);
      return fechaOrden.getTime() === dia.getTime();
    });

    const completadas = ordenesDelDia.filter(o => o.IdEstado === 5).length;
    const canceladas = ordenesDelDia.filter(o => o.IdEstado === 6).length;
    const ingresos = ordenesDelDia
      .filter(o => o.IdEstado === 5)
      .reduce((sum, o) => sum + calcularTotal(o), 0);

    return {
      dia: dia.toLocaleDateString('es-ES', { weekday: 'short', day: 'numeric' }),
      total: ordenesDelDia.length,
      completadas,
      canceladas,
      ingresos: Math.round(ingresos)
    };
  });

  // Órdenes por estado
  const ordenesPorEstado = [
    { nombre: 'Pendiente', valor: ordenes.filter(o => o.IdEstado === 2).length, color: '#facc15' },
    { nombre: 'En Preparación', valor: ordenes.filter(o => o.IdEstado === 3).length, color: '#3b82f6' },
    { nombre: 'Listo', valor: ordenes.filter(o => o.IdEstado === 4).length, color: '#22c55e' },
    { nombre: 'Entregado', valor: ordenes.filter(o => o.IdEstado === 5).length, color: '#64748b' },
    { nombre: 'Cancelado', valor: ordenes.filter(o => o.IdEstado === 6).length, color: '#ef4444' },
  ];

  // Tipos de producto más vendidos
  const ventasPorTipo: Record<string, number> = {};
  ordenes.forEach(orden => {
    if (orden.IdEstado === 5) {
      orden.Productos?.forEach(po => {
        const tipoProducto = po.Producto?.TipoProducto || 'Otro';
        ventasPorTipo[tipoProducto] = (ventasPorTipo[tipoProducto] || 0) + (po.Cantidad || 1);
      });
    }
  });

  const ventasPorTipoData = Object.entries(ventasPorTipo).map(([tipo, cantidad]) => ({
    tipo,
    cantidad
  }));

  const formatCurrency = (valor: number) => {
    return new Intl.NumberFormat('es-CO', {
      style: 'currency',
      currency: 'COP',
      minimumFractionDigits: 0,
    }).format(valor);
  };

  const COLORS = ['#3b82f6', '#22c55e', '#facc15', '#ef4444', '#8b5cf6', '#ec4899'];

  return (
    <div className="space-y-6">
      {/* Tarjetas de estadísticas principales */}
      <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm">Ingresos Hoy</CardTitle>
            <DollarSign className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="flex items-baseline justify-between">
              <div>
                <div className="text-2xl">{formatCurrency(ingresosHoy)}</div>
                <p className="text-xs text-muted-foreground mt-1">
                  {ordenesHoy.filter(o => o.IdEstado === 5).length} órdenes completadas
                </p>
              </div>
              {ingresosHoy > 0 && (
                <div className="flex items-center text-sm text-green-600">
                  <ArrowUp className="h-4 w-4" />
                </div>
              )}
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm">Órdenes Activas</CardTitle>
            <ShoppingCart className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl">{ordenesActivas.length}</div>
            <p className="text-xs text-muted-foreground mt-1">
              {ordenes.filter(o => o.IdEstado === 3).length} en preparación
            </p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm">Promedio por Orden</CardTitle>
            <Receipt className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl">{formatCurrency(promedioOrden)}</div>
            <p className="text-xs text-muted-foreground mt-1">
              {ordenesCompletadas.length} órdenes totales
            </p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm">Tiempo Promedio</CardTitle>
            <Clock className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl">{tiempoPromedioPreparacion} min</div>
            <p className="text-xs text-muted-foreground mt-1">
              De preparación
            </p>
          </CardContent>
        </Card>
      </div>

      {/* Estadísticas adicionales */}
      <div className="grid gap-4 md:grid-cols-3">
        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm">Total Órdenes</CardTitle>
            <TrendingUp className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl">{ordenes.length}</div>
            <div className="flex items-center gap-4 mt-2 text-xs">
              <span className="text-green-600">✓ {ordenesCompletadas.length} completadas</span>
              <span className="text-red-600">✗ {ordenesCanceladas.length} canceladas</span>
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm">Personal Activo</CardTitle>
            <Users className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl">{usuarios.filter(u => u.IdEstado === 1).length}</div>
            <div className="flex items-center gap-3 mt-2 text-xs text-muted-foreground">
              <span>{usuarios.filter(u => u.IdTipoUsuario === 2).length} meseros</span>
              <span>{usuarios.filter(u => u.IdTipoUsuario === 3).length} cocina</span>
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm">Productos Activos</CardTitle>
            <Package className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl">{productos.filter(p => p.IdEstado === 1).length}</div>
            <p className="text-xs text-muted-foreground mt-1">
              En el menú
            </p>
          </CardContent>
        </Card>
      </div>

      {/* Gráficas */}
      <div className="grid gap-4 md:grid-cols-2">
        {/* Órdenes por día */}
        <Card>
          <CardHeader>
            <CardTitle className="text-base">Órdenes Últimos 7 Días</CardTitle>
          </CardHeader>
          <CardContent>
            <ResponsiveContainer width="100%" height={250}>
              <BarChart data={ordenesPorDia}>
                <CartesianGrid strokeDasharray="3 3" />
                <XAxis dataKey="dia" />
                <YAxis />
                <Tooltip />
                <Legend />
                <Bar dataKey="completadas" fill="#22c55e" name="Completadas" />
                <Bar dataKey="canceladas" fill="#ef4444" name="Canceladas" />
              </BarChart>
            </ResponsiveContainer>
          </CardContent>
        </Card>

        {/* Órdenes por estado */}
        <Card>
          <CardHeader>
            <CardTitle className="text-base">Distribución por Estado</CardTitle>
          </CardHeader>
          <CardContent>
            <ResponsiveContainer width="100%" height={250}>
              <PieChart>
                <Pie
                  data={ordenesPorEstado}
                  cx="50%"
                  cy="50%"
                  labelLine={false}
                  label={({ nombre, valor }) => valor > 0 ? `${nombre}: ${valor}` : ''}
                  outerRadius={80}
                  fill="#8884d8"
                  dataKey="valor"
                >
                  {ordenesPorEstado.map((entry, index) => (
                    <Cell key={`cell-${index}`} fill={entry.color} />
                  ))}
                </Pie>
                <Tooltip />
              </PieChart>
            </ResponsiveContainer>
          </CardContent>
        </Card>
      </div>

      {/* Ingresos por día y productos más vendidos */}
      <div className="grid gap-4 md:grid-cols-2">
        {/* Ingresos por día */}
        <Card>
          <CardHeader>
            <CardTitle className="text-base">Ingresos por Día</CardTitle>
          </CardHeader>
          <CardContent>
            <ResponsiveContainer width="100%" height={250}>
              <LineChart data={ordenesPorDia}>
                <CartesianGrid strokeDasharray="3 3" />
                <XAxis dataKey="dia" />
                <YAxis />
                <Tooltip formatter={(value) => formatCurrency(Number(value))} />
                <Legend />
                <Line 
                  type="monotone" 
                  dataKey="ingresos" 
                  stroke="#3b82f6" 
                  strokeWidth={2}
                  name="Ingresos"
                />
              </LineChart>
            </ResponsiveContainer>
          </CardContent>
        </Card>

        {/* Productos más vendidos */}
        <Card>
          <CardHeader>
            <CardTitle className="text-base">Top 5 Productos</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="space-y-4">
              {topProductos.length > 0 ? (
                topProductos.map((producto, index) => (
                  <div key={index} className="flex items-center justify-between">
                    <div className="flex items-center gap-3 flex-1">
                      <div className="flex items-center justify-center w-8 h-8 rounded-full bg-primary/10 text-primary">
                        {index + 1}
                      </div>
                      <div className="flex-1">
                        <p className="text-sm truncate">{producto.nombre}</p>
                        <p className="text-xs text-muted-foreground">
                          {producto.cantidad} vendidos
                        </p>
                      </div>
                    </div>
                    <div className="text-sm">
                      {formatCurrency(producto.ingresos)}
                    </div>
                  </div>
                ))
              ) : (
                <p className="text-sm text-muted-foreground text-center py-4">
                  No hay datos de productos vendidos
                </p>
              )}
            </div>
          </CardContent>
        </Card>
      </div>

      {/* Ventas por tipo de producto */}
      {ventasPorTipoData.length > 0 && (
        <Card>
          <CardHeader>
            <CardTitle className="text-base">Ventas por Categoría</CardTitle>
          </CardHeader>
          <CardContent>
            <ResponsiveContainer width="100%" height={250}>
              <BarChart data={ventasPorTipoData} layout="vertical">
                <CartesianGrid strokeDasharray="3 3" />
                <XAxis type="number" />
                <YAxis dataKey="tipo" type="category" width={100} />
                <Tooltip />
                <Bar dataKey="cantidad" fill="#3b82f6" name="Cantidad">
                  {ventasPorTipoData.map((entry, index) => (
                    <Cell key={`cell-${index}`} fill={COLORS[index % COLORS.length]} />
                  ))}
                </Bar>
              </BarChart>
            </ResponsiveContainer>
          </CardContent>
        </Card>
      )}
    </div>
  );
}
