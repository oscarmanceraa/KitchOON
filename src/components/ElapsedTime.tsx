import { useState, useEffect } from 'react';
import { Timer } from 'lucide-react';
import { formatElapsedTime, getElapsedMinutes, getTimeBgColor } from '../lib/dateUtils';
import { Badge } from './ui/badge';

interface ElapsedTimeProps {
  startDate: Date | string;
  endDate?: Date | string;
  showIcon?: boolean;
  variant?: 'badge' | 'text';
  thresholds?: {
    warning: number; // minutos
    danger: number;  // minutos
  };
  className?: string;
}

export function ElapsedTime({
  startDate,
  endDate,
  showIcon = true,
  variant = 'text',
  thresholds = { warning: 30, danger: 60 },
  className = ''
}: ElapsedTimeProps) {
  const [elapsed, setElapsed] = useState(formatElapsedTime(startDate, endDate));
  const [minutes, setMinutes] = useState(getElapsedMinutes(startDate, endDate));

  useEffect(() => {
    // Si endDate está definido, no actualizar (tiempo fijo)
    if (endDate) {
      setElapsed(formatElapsedTime(startDate, endDate));
      setMinutes(getElapsedMinutes(startDate, endDate));
      return;
    }

    // Actualizar cada minuto si no hay endDate
    const timer = setInterval(() => {
      setElapsed(formatElapsedTime(startDate));
      setMinutes(getElapsedMinutes(startDate));
    }, 60000); // Actualizar cada minuto

    // Actualización inicial
    setElapsed(formatElapsedTime(startDate));
    setMinutes(getElapsedMinutes(startDate));

    return () => clearInterval(timer);
  }, [startDate, endDate]);

  const colorClass = getTimeBgColor(minutes, thresholds);

  if (variant === 'badge') {
    return (
      <Badge className={`${colorClass} ${className}`}>
        {showIcon && <Timer className="w-3 h-3 mr-1" />}
        {elapsed}
      </Badge>
    );
  }

  return (
    <div className={`flex items-center gap-1 ${className}`}>
      {showIcon && <Timer className="w-4 h-4" />}
      <span className="font-mono text-sm">{elapsed}</span>
    </div>
  );
}
