/**
 * Servicio de API para conectar con el backend de Django
 */

const API_BASE_URL = import.meta.env.VITE_API_URL || 'http://localhost:8000/api';

interface ApiError {
  message: string;
  status?: number;
}

class ApiService {
  private baseUrl: string;

  constructor(baseUrl: string) {
    this.baseUrl = baseUrl;
  }

  private async request<T>(
    endpoint: string,
    options: RequestInit = {}
  ): Promise<T> {
    const url = `${this.baseUrl}${endpoint}`;
    
    const config: RequestInit = {
      ...options,
      headers: {
        'Content-Type': 'application/json',
        ...options.headers,
      },
    };

    try {
      const response = await fetch(url, config);
      
      if (!response.ok) {
        const error: ApiError = {
          message: `Error ${response.status}: ${response.statusText}`,
          status: response.status,
        };
        throw error;
      }

      const data = await response.json();
      return data;
    } catch (error) {
      console.error('API Error:', error);
      throw error;
    }
  }

  // Estados
  async getEstados() {
    return this.request('/estados/');
  }

  async getEstado(id: number) {
    return this.request(`/estados/${id}/`);
  }

  // Tipos de Producto
  async getTiposProducto() {
    return this.request('/tipos-producto/');
  }

  async getTipoProducto(id: number) {
    return this.request(`/tipos-producto/${id}/`);
  }

  // Tipos de Usuario
  async getTiposUsuario() {
    return this.request('/tipos-usuario/');
  }

  async getTipoUsuario(id: number) {
    return this.request(`/tipos-usuario/${id}/`);
  }

  // Personas
  async getPersonas() {
    return this.request('/personas/');
  }

  async getPersona(id: number) {
    return this.request(`/personas/${id}/`);
  }

  async createPersona(data: any) {
    return this.request('/personas/', {
      method: 'POST',
      body: JSON.stringify(data),
    });
  }

  async updatePersona(id: number, data: any) {
    return this.request(`/personas/${id}/`, {
      method: 'PUT',
      body: JSON.stringify(data),
    });
  }

  async deletePersona(id: number) {
    return this.request(`/personas/${id}/`, {
      method: 'DELETE',
    });
  }

  // Usuarios
  async login(username: string, password: string) {
    return this.request('/usuarios/login/', {
      method: 'POST',
      body: JSON.stringify({ username, password }),
    });
  }

  async getUsuarios() {
    return this.request('/usuarios/');
  }

  async getUsuariosActivos() {
    return this.request('/usuarios/activos/');
  }

  async getUsuario(id: number) {
    return this.request(`/usuarios/${id}/`);
  }

  async createUsuario(data: any) {
    return this.request('/usuarios/', {
      method: 'POST',
      body: JSON.stringify(data),
    });
  }

  async updateUsuario(id: number, data: any) {
    return this.request(`/usuarios/${id}/`, {
      method: 'PATCH',
      body: JSON.stringify(data),
    });
  }

  async deleteUsuario(id: number) {
    return this.request(`/usuarios/${id}/`, {
      method: 'DELETE',
    });
  }

  // Productos
  async getProductos() {
    return this.request('/productos/');
  }

  async getProductosDisponibles() {
    return this.request('/productos/disponibles/');
  }

  async getProducto(id: number) {
    return this.request(`/productos/${id}/`);
  }

  async createProducto(data: any) {
    return this.request('/productos/', {
      method: 'POST',
      body: JSON.stringify(data),
    });
  }

  async updateProducto(id: number, data: any) {
    return this.request(`/productos/${id}/`, {
      method: 'PATCH',
      body: JSON.stringify(data),
    });
  }

  async deleteProducto(id: number) {
    return this.request(`/productos/${id}/`, {
      method: 'DELETE',
    });
  }

  // Mesas
  async getMesas() {
    return this.request('/mesas/');
  }

  async getMesasDisponibles() {
    return this.request('/mesas/disponibles/');
  }

  async getMesa(id: number) {
    return this.request(`/mesas/${id}/`);
  }

  async createMesa(data: any) {
    return this.request('/mesas/', {
      method: 'POST',
      body: JSON.stringify(data),
    });
  }

  async updateMesa(id: number, data: any) {
    return this.request(`/mesas/${id}/`, {
      method: 'PATCH',
      body: JSON.stringify(data),
    });
  }

  async deleteMesa(id: number) {
    return this.request(`/mesas/${id}/`, {
      method: 'DELETE',
    });
  }

  // Órdenes
  async getOrdenes() {
    return this.request('/ordenes/');
  }

  async getOrdenesActivas() {
    return this.request('/ordenes/activas/');
  }

  async getOrdenesPorMesero(meseroId: number) {
    return this.request(`/ordenes/por_mesero/?mesero_id=${meseroId}`);
  }

  async getOrden(id: number) {
    return this.request(`/ordenes/${id}/`);
  }

  async createOrden(data: any) {
    return this.request('/ordenes/', {
      method: 'POST',
      body: JSON.stringify(data),
    });
  }

  async updateOrden(id: number, data: any) {
    return this.request(`/ordenes/${id}/`, {
      method: 'PATCH',
      body: JSON.stringify(data),
    });
  }

  async actualizarEstadoOrden(id: number, idEstado: number) {
    return this.request(`/ordenes/${id}/actualizar_estado/`, {
      method: 'PATCH',
      body: JSON.stringify({ IdEstado: idEstado }),
    });
  }

  async deleteOrden(id: number) {
    return this.request(`/ordenes/${id}/`, {
      method: 'DELETE',
    });
  }

  async getEstadisticas() {
    return this.request('/ordenes/estadisticas/');
  }

  // Mensajes
  async getMensajes() {
    return this.request('/mensajes/');
  }

  async getConversacion(usuario1Id: number, usuario2Id: number) {
    return this.request(`/mensajes/conversacion/?usuario1=${usuario1Id}&usuario2=${usuario2Id}`);
  }

  async getConversaciones(usuarioId: number) {
    return this.request(`/mensajes/conversaciones/?usuario_id=${usuarioId}`);
  }

  async getMensajesNoLeidos(usuarioId: number) {
    return this.request(`/mensajes/no_leidos/?usuario_id=${usuarioId}`);
  }

  async enviarMensaje(data: any) {
    return this.request('/mensajes/', {
      method: 'POST',
      body: JSON.stringify(data),
    });
  }

  async marcarMensajesLeidos(usuarioId: number, emisorId: number) {
    return this.request('/mensajes/marcar_leidos/', {
      method: 'POST',
      body: JSON.stringify({
        usuario_id: usuarioId,
        emisor_id: emisorId,
      }),
    });
  }
}

// Exportar instancia del servicio
export const api = new ApiService(API_BASE_URL);

// Exportar también la clase por si se necesita crear instancias personalizadas
export default ApiService;
