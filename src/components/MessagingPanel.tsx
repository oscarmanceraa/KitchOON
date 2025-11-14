import { useState, useEffect, useRef } from 'react';
import { Card, CardContent, CardHeader, CardTitle } from './ui/card';
import { Button } from './ui/button';
import { Input } from './ui/input';
import { ScrollArea } from './ui/scroll-area';
import { Badge } from './ui/badge';
import { Avatar, AvatarFallback } from './ui/avatar';
import { Send, MessageSquare, X } from 'lucide-react';
import { NewConversationDialog } from './NewConversationDialog';
import type { Usuario, Mensaje } from '../types/database';
import * as DB from '../lib/mockDatabase';

interface MessagingPanelProps {
  currentUser: Usuario;
  onClose?: () => void;
}

export function MessagingPanel({ currentUser, onClose }: MessagingPanelProps) {
  const [conversaciones, setConversaciones] = useState<number[]>([]);
  const [conversacionActiva, setConversacionActiva] = useState<number | null>(null);
  const [mensajes, setMensajes] = useState<Mensaje[]>([]);
  const [nuevoMensaje, setNuevoMensaje] = useState('');
  const [mensajesNoLeidos, setMensajesNoLeidos] = useState<Record<number, number>>({});
  const scrollRef = useRef<HTMLDivElement>(null);

  // Cargar conversaciones
  useEffect(() => {
    const conv = DB.getConversaciones(currentUser.IdUsuario);
    setConversaciones(conv);
    
    // Contar mensajes no leídos por conversación
    const noLeidos: Record<number, number> = {};
    conv.forEach(idUsuario => {
      const mensajesConv = DB.getMensajesEntre(currentUser.IdUsuario, idUsuario);
      noLeidos[idUsuario] = mensajesConv.filter(
        m => m.IdReceptor === currentUser.IdUsuario && !m.Leido
      ).length;
    });
    setMensajesNoLeidos(noLeidos);
  }, [currentUser.IdUsuario]);

  // Cargar mensajes de la conversación activa
  useEffect(() => {
    if (conversacionActiva) {
      const msgs = DB.getMensajesEntre(currentUser.IdUsuario, conversacionActiva);
      setMensajes(msgs);
      
      // Marcar mensajes como leídos
      DB.marcarMensajesComoLeidos(currentUser.IdUsuario, conversacionActiva);
      
      // Actualizar contador de no leídos
      setMensajesNoLeidos(prev => ({
        ...prev,
        [conversacionActiva]: 0
      }));
    }
  }, [conversacionActiva, currentUser.IdUsuario]);

  // Scroll automático al último mensaje
  useEffect(() => {
    if (scrollRef.current) {
      scrollRef.current.scrollTop = scrollRef.current.scrollHeight;
    }
  }, [mensajes]);

  const enviarMensaje = () => {
    if (!nuevoMensaje.trim() || !conversacionActiva) return;

    const mensaje: Mensaje = {
      IdMensaje: DB.getMensajes().length + 1,
      IdEmisor: currentUser.IdUsuario,
      IdReceptor: conversacionActiva,
      Mensaje: nuevoMensaje,
      FechaEnvio: new Date(),
      Leido: false,
    };

    DB.enviarMensaje(mensaje);
    setMensajes([...mensajes, mensaje]);
    setNuevoMensaje('');
  };

  const getUsuarioInfo = (idUsuario: number) => {
    const usuario = DB.getUsuario(idUsuario);
    if (!usuario) return { nombre: 'Usuario', iniciales: 'U' };
    
    const persona = DB.getPersona(usuario.IdPersona);
    if (!persona) return { nombre: usuario.Username, iniciales: usuario.Username.substring(0, 2).toUpperCase() };
    
    const nombre = DB.getNombreCompleto(persona);
    const iniciales = `${persona.PrimerNombre[0]}${persona.PrimerApellido[0]}`.toUpperCase();
    
    return { nombre, iniciales };
  };

  const formatearHora = (fecha: Date) => {
    return new Date(fecha).toLocaleTimeString('es-ES', { 
      hour: '2-digit', 
      minute: '2-digit' 
    });
  };

  const formatearFechaRelativa = (fecha: Date) => {
    const ahora = new Date();
    const diff = ahora.getTime() - new Date(fecha).getTime();
    const minutos = Math.floor(diff / 60000);
    
    if (minutos < 1) return 'Ahora';
    if (minutos < 60) return `${minutos}m`;
    
    const horas = Math.floor(minutos / 60);
    if (horas < 24) return `${horas}h`;
    
    const dias = Math.floor(horas / 24);
    return `${dias}d`;
  };

  return (
    <Card className="w-full h-full flex flex-col">
      <CardHeader className="flex flex-row items-center justify-between">
        <div className="flex items-center gap-2">
          <MessageSquare className="w-5 h-5" />
          <CardTitle>Mensajes</CardTitle>
        </div>
        {onClose && (
          <Button variant="ghost" size="sm" onClick={onClose}>
            <X className="w-4 h-4" />
          </Button>
        )}
      </CardHeader>
      <CardContent className="flex-1 flex gap-4 p-0 overflow-hidden">
        {/* Lista de conversaciones */}
        <div className="w-80 border-r flex flex-col">
          <div className="p-4 border-b">
            <div className="flex items-center justify-between mb-3">
              <h3>Conversaciones</h3>
            </div>
            <NewConversationDialog 
              currentUser={currentUser}
              onSelectUser={(idUsuario) => setConversacionActiva(idUsuario)}
            />
          </div>
          <ScrollArea className="flex-1">
            <div className="p-2">
              {conversaciones.length === 0 ? (
                <p className="text-center text-muted-foreground p-4">
                  No hay conversaciones
                </p>
              ) : (
                conversaciones.map(idUsuario => {
                  const { nombre, iniciales } = getUsuarioInfo(idUsuario);
                  const ultimoMensaje = DB.getUltimoMensaje(currentUser.IdUsuario, idUsuario);
                  const noLeidos = mensajesNoLeidos[idUsuario] || 0;

                  return (
                    <button
                      key={idUsuario}
                      onClick={() => setConversacionActiva(idUsuario)}
                      className={`w-full p-3 rounded-lg text-left hover:bg-accent transition-colors ${
                        conversacionActiva === idUsuario ? 'bg-accent' : ''
                      }`}
                    >
                      <div className="flex items-start gap-3">
                        <Avatar>
                          <AvatarFallback>{iniciales}</AvatarFallback>
                        </Avatar>
                        <div className="flex-1 min-w-0">
                          <div className="flex items-center justify-between gap-2">
                            <span className="truncate">{nombre}</span>
                            {ultimoMensaje && (
                              <span className="text-xs text-muted-foreground">
                                {formatearFechaRelativa(ultimoMensaje.FechaEnvio)}
                              </span>
                            )}
                          </div>
                          {ultimoMensaje && (
                            <div className="flex items-center justify-between gap-2">
                              <p className="text-sm text-muted-foreground truncate">
                                {ultimoMensaje.Mensaje}
                              </p>
                              {noLeidos > 0 && (
                                <Badge variant="default" className="h-5 min-w-5 px-1 flex items-center justify-center">
                                  {noLeidos}
                                </Badge>
                              )}
                            </div>
                          )}
                        </div>
                      </div>
                    </button>
                  );
                })
              )}
            </div>
          </ScrollArea>
        </div>

        {/* Área de chat */}
        <div className="flex-1 flex flex-col">
          {conversacionActiva ? (
            <>
              {/* Header de conversación */}
              <div className="p-4 border-b">
                <div className="flex items-center gap-3">
                  <Avatar>
                    <AvatarFallback>
                      {getUsuarioInfo(conversacionActiva).iniciales}
                    </AvatarFallback>
                  </Avatar>
                  <div>
                    <h3>{getUsuarioInfo(conversacionActiva).nombre}</h3>
                    <p className="text-sm text-muted-foreground">
                      {DB.getTipoUsuario(DB.getUsuario(conversacionActiva)?.IdTipoUsuario || 0)?.TipoUsuario}
                    </p>
                  </div>
                </div>
              </div>

              {/* Mensajes */}
              <ScrollArea className="flex-1 p-4" ref={scrollRef}>
                <div className="space-y-4">
                  {mensajes.map((mensaje, index) => {
                    const esMio = mensaje.IdEmisor === currentUser.IdUsuario;
                    
                    return (
                      <div
                        key={index}
                        className={`flex ${esMio ? 'justify-end' : 'justify-start'}`}
                      >
                        <div
                          className={`max-w-[70%] rounded-lg px-4 py-2 ${
                            esMio
                              ? 'bg-primary text-primary-foreground'
                              : 'bg-muted'
                          }`}
                        >
                          <p>{mensaje.Mensaje}</p>
                          <p className={`text-xs mt-1 ${
                            esMio ? 'text-primary-foreground/70' : 'text-muted-foreground'
                          }`}>
                            {formatearHora(mensaje.FechaEnvio)}
                          </p>
                        </div>
                      </div>
                    );
                  })}
                </div>
              </ScrollArea>

              {/* Input para nuevo mensaje */}
              <div className="p-4 border-t">
                <form
                  onSubmit={(e) => {
                    e.preventDefault();
                    enviarMensaje();
                  }}
                  className="flex gap-2"
                >
                  <Input
                    value={nuevoMensaje}
                    onChange={(e) => setNuevoMensaje(e.target.value)}
                    placeholder="Escribe un mensaje..."
                  />
                  <Button type="submit" size="icon" disabled={!nuevoMensaje.trim()}>
                    <Send className="w-4 h-4" />
                  </Button>
                </form>
              </div>
            </>
          ) : (
            <div className="flex-1 flex items-center justify-center">
              <div className="text-center text-muted-foreground">
                <MessageSquare className="w-12 h-12 mx-auto mb-2 opacity-50" />
                <p>Selecciona una conversación para comenzar</p>
              </div>
            </div>
          )}
        </div>
      </CardContent>
    </Card>
  );
}