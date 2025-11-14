import { useState } from 'react';
import { Button } from './ui/button';
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from './ui/dialog';
import { Avatar, AvatarFallback } from './ui/avatar';
import { Badge } from './ui/badge';
import { Plus, MessageSquare } from 'lucide-react';
import type { Usuario } from '../types/database';
import * as DB from '../lib/mockDatabase';

interface NewConversationDialogProps {
  currentUser: Usuario;
  onSelectUser: (idUsuario: number) => void;
}

export function NewConversationDialog({ currentUser, onSelectUser }: NewConversationDialogProps) {
  const [open, setOpen] = useState(false);

  // Obtener todos los usuarios excepto el actual
  const usuarios = DB.getUsuarios().filter(u => u.IdUsuario !== currentUser.IdUsuario && u.IdEstado === 1);

  const handleSelectUser = (idUsuario: number) => {
    onSelectUser(idUsuario);
    setOpen(false);
  };

  const getUsuarioInfo = (usuario: Usuario) => {
    const persona = DB.getPersona(usuario.IdPersona);
    const tipoUsuario = DB.getTipoUsuario(usuario.IdTipoUsuario);
    
    if (!persona) return { 
      nombre: usuario.Username, 
      iniciales: usuario.Username.substring(0, 2).toUpperCase(),
      tipo: tipoUsuario?.TipoUsuario || 'Usuario'
    };
    
    const nombre = DB.getNombreCompleto(persona);
    const iniciales = `${persona.PrimerNombre[0]}${persona.PrimerApellido[0]}`.toUpperCase();
    
    return { nombre, iniciales, tipo: tipoUsuario?.TipoUsuario || 'Usuario' };
  };

  return (
    <Dialog open={open} onOpenChange={setOpen}>
      <DialogTrigger asChild>
        <Button size="sm" variant="outline" className="gap-2">
          <Plus className="w-4 h-4" />
          Nueva Conversación
        </Button>
      </DialogTrigger>
      <DialogContent>
        <DialogHeader>
          <DialogTitle className="flex items-center gap-2">
            <MessageSquare className="w-5 h-5" />
            Iniciar Conversación
          </DialogTitle>
          <DialogDescription>
            Selecciona un usuario para comenzar una conversación
          </DialogDescription>
        </DialogHeader>
        <div className="space-y-2 max-h-96 overflow-y-auto">
          {usuarios.length === 0 ? (
            <p className="text-center text-muted-foreground py-4">
              No hay usuarios disponibles
            </p>
          ) : (
            usuarios.map(usuario => {
              const { nombre, iniciales, tipo } = getUsuarioInfo(usuario);
              
              return (
                <button
                  key={usuario.IdUsuario}
                  onClick={() => handleSelectUser(usuario.IdUsuario)}
                  className="w-full p-3 rounded-lg hover:bg-accent transition-colors text-left flex items-center gap-3"
                >
                  <Avatar>
                    <AvatarFallback>{iniciales}</AvatarFallback>
                  </Avatar>
                  <div className="flex-1">
                    <p>{nombre}</p>
                    <p className="text-sm text-muted-foreground">{tipo}</p>
                  </div>
                  <Badge variant="outline">{usuario.Username}</Badge>
                </button>
              );
            })
          )}
        </div>
      </DialogContent>
    </Dialog>
  );
}