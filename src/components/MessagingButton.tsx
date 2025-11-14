import { useState } from 'react';
import { Button } from './ui/button';
import { Badge } from './ui/badge';
import { Sheet, SheetContent, SheetTitle, SheetDescription, SheetTrigger } from './ui/sheet';
import { MessageSquare } from 'lucide-react';
import { MessagingPanel } from './MessagingPanel';
import type { Usuario } from '../types/database';
import * as DB from '../lib/mockDatabase';

interface MessagingButtonProps {
  currentUser: Usuario;
}

export function MessagingButton({ currentUser }: MessagingButtonProps) {
  const [open, setOpen] = useState(false);
  const [mensajesNoLeidos, setMensajesNoLeidos] = useState(
    DB.getMensajesNoLeidos(currentUser.IdUsuario)
  );

  // Actualizar contador de mensajes no leídos cuando se abre/cierra
  const handleOpenChange = (isOpen: boolean) => {
    setOpen(isOpen);
    if (!isOpen) {
      setMensajesNoLeidos(DB.getMensajesNoLeidos(currentUser.IdUsuario));
    }
  };

  return (
    <Sheet open={open} onOpenChange={handleOpenChange}>
      <SheetTrigger asChild>
        <Button variant="outline" size="icon" className="relative">
          <MessageSquare className="w-5 h-5" />
          {mensajesNoLeidos > 0 && (
            <Badge 
              variant="destructive" 
              className="absolute -top-2 -right-2 h-5 min-w-5 px-1 flex items-center justify-center"
            >
              {mensajesNoLeidos}
            </Badge>
          )}
        </Button>
      </SheetTrigger>
      <SheetContent side="right" className="w-full sm:max-w-4xl p-0">
        <SheetTitle className="sr-only">Panel de Mensajes</SheetTitle>
        <SheetDescription className="sr-only">
          Visualiza y gestiona tus conversaciones
        </SheetDescription>
        <div className="h-full">
          <MessagingPanel 
            currentUser={currentUser} 
            onClose={() => setOpen(false)}
          />
        </div>
      </SheetContent>
    </Sheet>
  );
}