import { useState, useEffect } from 'react';
import { Clock } from 'lucide-react';
import { formatTime, formatDate } from '../lib/dateUtils';

interface LiveClockProps {
  showDate?: boolean;
  showSeconds?: boolean;
  className?: string;
}

export function LiveClock({ showDate = true, showSeconds = true, className = '' }: LiveClockProps) {
  const [currentTime, setCurrentTime] = useState(new Date());

  useEffect(() => {
    const timer = setInterval(() => {
      setCurrentTime(new Date());
    }, showSeconds ? 1000 : 60000); // Actualizar cada segundo o cada minuto

    return () => clearInterval(timer);
  }, [showSeconds]);

  const timeFormat = showSeconds ? 'HH:mm:ss' : 'HH:mm';

  return (
    <div className={`flex items-center gap-2 ${className}`}>
      <Clock className="w-4 h-4 text-muted-foreground" />
      <div className="flex flex-col">
        <span className="font-mono">{formatTime(currentTime, timeFormat)}</span>
        {showDate && (
          <span className="text-xs text-muted-foreground">
            {formatDate(currentTime, 'EEEE, dd MMM yyyy')}
          </span>
        )}
      </div>
    </div>
  );
}
