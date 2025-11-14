/**
 * Utilidades para manejo de fechas, horas y tiempos
 */

import { format, formatDistanceToNow, differenceInMinutes, differenceInHours, differenceInDays, isToday, isYesterday, isSameWeek, parseISO, startOfDay, endOfDay, startOfWeek, endOfWeek, startOfMonth, endOfMonth } from 'date-fns';
import { es } from 'date-fns/locale';

/**
 * Formatea una fecha a un string legible
 */
export const formatDate = (date: Date | string, formatStr: string = 'PPP'): string => {
  const d = typeof date === 'string' ? parseISO(date) : date;
  return format(d, formatStr, { locale: es });
};

/**
 * Formatea una hora a un string legible
 */
export const formatTime = (date: Date | string, formatStr: string = 'p'): string => {
  const d = typeof date === 'string' ? parseISO(date) : date;
  return format(d, formatStr, { locale: es });
};

/**
 * Formatea fecha y hora completa
 */
export const formatDateTime = (date: Date | string, formatStr: string = 'PPp'): string => {
  const d = typeof date === 'string' ? parseISO(date) : date;
  return format(d, formatStr, { locale: es });
};

/**
 * Formatea fecha de manera corta (dd/MM/yyyy)
 */
export const formatShortDate = (date: Date | string): string => {
  const d = typeof date === 'string' ? parseISO(date) : date;
  return format(d, 'dd/MM/yyyy', { locale: es });
};

/**
 * Formatea hora de manera corta (HH:mm)
 */
export const formatShortTime = (date: Date | string): string => {
  const d = typeof date === 'string' ? parseISO(date) : date;
  return format(d, 'HH:mm', { locale: es });
};

/**
 * Formatea fecha y hora de manera corta
 */
export const formatShortDateTime = (date: Date | string): string => {
  const d = typeof date === 'string' ? parseISO(date) : date;
  return format(d, 'dd/MM/yyyy HH:mm', { locale: es });
};

/**
 * Retorna tiempo relativo (hace 5 minutos, hace 2 horas, etc.)
 */
export const formatRelativeTime = (date: Date | string): string => {
  const d = typeof date === 'string' ? parseISO(date) : date;
  return formatDistanceToNow(d, { locale: es, addSuffix: true });
};

/**
 * Calcula tiempo transcurrido en minutos
 */
export const getElapsedMinutes = (startDate: Date | string, endDate?: Date | string): number => {
  const start = typeof startDate === 'string' ? parseISO(startDate) : startDate;
  const end = endDate ? (typeof endDate === 'string' ? parseISO(endDate) : endDate) : new Date();
  return differenceInMinutes(end, start);
};

/**
 * Calcula tiempo transcurrido en horas
 */
export const getElapsedHours = (startDate: Date | string, endDate?: Date | string): number => {
  const start = typeof startDate === 'string' ? parseISO(startDate) : startDate;
  const end = endDate ? (typeof endDate === 'string' ? parseISO(endDate) : endDate) : new Date();
  return differenceInHours(end, start);
};

/**
 * Calcula tiempo transcurrido en días
 */
export const getElapsedDays = (startDate: Date | string, endDate?: Date | string): number => {
  const start = typeof startDate === 'string' ? parseISO(startDate) : startDate;
  const end = endDate ? (typeof endDate === 'string' ? parseISO(endDate) : endDate) : new Date();
  return differenceInDays(end, start);
};

/**
 * Formatea tiempo transcurrido de manera legible
 */
export const formatElapsedTime = (startDate: Date | string, endDate?: Date | string): string => {
  const minutes = getElapsedMinutes(startDate, endDate);
  
  if (minutes < 1) return 'Recién creado';
  if (minutes < 60) return `${minutes} min`;
  
  const hours = Math.floor(minutes / 60);
  const remainingMinutes = minutes % 60;
  
  if (hours < 24) {
    if (remainingMinutes === 0) return `${hours}h`;
    return `${hours}h ${remainingMinutes}min`;
  }
  
  const days = Math.floor(hours / 24);
  const remainingHours = hours % 24;
  
  if (remainingHours === 0) return `${days}d`;
  return `${days}d ${remainingHours}h`;
};

/**
 * Verifica si una fecha es de hoy
 */
export const isDateToday = (date: Date | string): boolean => {
  const d = typeof date === 'string' ? parseISO(date) : date;
  return isToday(d);
};

/**
 * Verifica si una fecha es de ayer
 */
export const isDateYesterday = (date: Date | string): boolean => {
  const d = typeof date === 'string' ? parseISO(date) : date;
  return isYesterday(d);
};

/**
 * Verifica si una fecha es de esta semana
 */
export const isDateThisWeek = (date: Date | string): boolean => {
  const d = typeof date === 'string' ? parseISO(date) : date;
  return isSameWeek(d, new Date(), { locale: es });
};

/**
 * Retorna etiqueta de fecha contextual (Hoy, Ayer, nombre del día, etc.)
 */
export const getDateLabel = (date: Date | string): string => {
  const d = typeof date === 'string' ? parseISO(date) : date;
  
  if (isToday(d)) return 'Hoy';
  if (isYesterday(d)) return 'Ayer';
  if (isSameWeek(d, new Date(), { locale: es })) {
    return format(d, 'EEEE', { locale: es }); // Nombre del día
  }
  
  return formatDate(d, 'PPP');
};

/**
 * Retorna objeto Date del inicio del día
 */
export const getStartOfDay = (date?: Date | string): Date => {
  const d = date ? (typeof date === 'string' ? parseISO(date) : date) : new Date();
  return startOfDay(d);
};

/**
 * Retorna objeto Date del fin del día
 */
export const getEndOfDay = (date?: Date | string): Date => {
  const d = date ? (typeof date === 'string' ? parseISO(date) : date) : new Date();
  return endOfDay(d);
};

/**
 * Retorna objeto Date del inicio de la semana
 */
export const getStartOfWeek = (date?: Date | string): Date => {
  const d = date ? (typeof date === 'string' ? parseISO(date) : date) : new Date();
  return startOfWeek(d, { locale: es });
};

/**
 * Retorna objeto Date del fin de la semana
 */
export const getEndOfWeek = (date?: Date | string): Date => {
  const d = date ? (typeof date === 'string' ? parseISO(date) : date) : new Date();
  return endOfWeek(d, { locale: es });
};

/**
 * Retorna objeto Date del inicio del mes
 */
export const getStartOfMonth = (date?: Date | string): Date => {
  const d = date ? (typeof date === 'string' ? parseISO(date) : date) : new Date();
  return startOfMonth(d);
};

/**
 * Retorna objeto Date del fin del mes
 */
export const getEndOfMonth = (date?: Date | string): Date => {
  const d = date ? (typeof date === 'string' ? parseISO(date) : date) : new Date();
  return endOfMonth(d);
};

/**
 * Formatea duración en minutos a string legible
 */
export const formatDuration = (minutes: number): string => {
  if (minutes < 1) return '< 1 min';
  if (minutes < 60) return `${Math.round(minutes)} min`;
  
  const hours = Math.floor(minutes / 60);
  const remainingMinutes = Math.round(minutes % 60);
  
  if (remainingMinutes === 0) return `${hours}h`;
  return `${hours}h ${remainingMinutes}min`;
};

/**
 * Retorna color basado en el tiempo transcurrido (para indicadores visuales)
 */
export const getTimeColor = (minutes: number, thresholds: { warning: number; danger: number }): string => {
  if (minutes >= thresholds.danger) return 'text-red-600';
  if (minutes >= thresholds.warning) return 'text-yellow-600';
  return 'text-green-600';
};

/**
 * Retorna clase de color de fondo basado en el tiempo transcurrido
 */
export const getTimeBgColor = (minutes: number, thresholds: { warning: number; danger: number }): string => {
  if (minutes >= thresholds.danger) return 'bg-red-100 text-red-800';
  if (minutes >= thresholds.warning) return 'bg-yellow-100 text-yellow-800';
  return 'bg-green-100 text-green-800';
};

/**
 * Parsea string ISO a Date
 */
export const parseDate = (dateString: string): Date => {
  return parseISO(dateString);
};

/**
 * Retorna fecha actual
 */
export const getCurrentDate = (): Date => {
  return new Date();
};

/**
 * Retorna timestamp actual
 */
export const getCurrentTimestamp = (): number => {
  return Date.now();
};

/**
 * Convierte Date a string ISO
 */
export const toISOString = (date: Date): string => {
  return date.toISOString();
};

/**
 * Formatea rango de fechas
 */
export const formatDateRange = (startDate: Date | string, endDate: Date | string): string => {
  const start = typeof startDate === 'string' ? parseISO(startDate) : startDate;
  const end = typeof endDate === 'string' ? parseISO(endDate) : endDate;
  
  return `${formatShortDate(start)} - ${formatShortDate(end)}`;
};

/**
 * Verifica si una fecha está en un rango
 */
export const isDateInRange = (date: Date | string, startDate: Date | string, endDate: Date | string): boolean => {
  const d = typeof date === 'string' ? parseISO(date) : date;
  const start = typeof startDate === 'string' ? parseISO(startDate) : startDate;
  const end = typeof endDate === 'string' ? parseISO(endDate) : endDate;
  
  return d >= start && d <= end;
};
