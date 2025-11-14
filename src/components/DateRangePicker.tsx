import { useState } from 'react';
import { Calendar } from 'lucide-react';
import { Button } from './ui/button';
import { Popover, PopoverContent, PopoverTrigger } from './ui/popover';
import { Calendar as CalendarComponent } from './ui/calendar';
import { formatShortDate, formatDateRange, getStartOfDay, getEndOfDay } from '../lib/dateUtils';

interface DateRangePickerProps {
  startDate?: Date;
  endDate?: Date;
  onRangeChange: (startDate: Date, endDate: Date) => void;
  className?: string;
}

export function DateRangePicker({
  startDate,
  endDate,
  onRangeChange,
  className = ''
}: DateRangePickerProps) {
  const [isOpen, setIsOpen] = useState(false);
  const [tempStartDate, setTempStartDate] = useState<Date | undefined>(startDate);
  const [tempEndDate, setTempEndDate] = useState<Date | undefined>(endDate);
  const [selectingStart, setSelectingStart] = useState(true);

  const handleDateSelect = (date: Date | undefined) => {
    if (!date) return;

    if (selectingStart) {
      setTempStartDate(getStartOfDay(date));
      setSelectingStart(false);
    } else {
      setTempEndDate(getEndOfDay(date));
      
      // Si la fecha de fin es antes que la de inicio, intercambiarlas
      if (tempStartDate && date < tempStartDate) {
        onRangeChange(getStartOfDay(date), getEndOfDay(tempStartDate));
      } else if (tempStartDate) {
        onRangeChange(getStartOfDay(tempStartDate), getEndOfDay(date));
      }
      
      setSelectingStart(true);
      setIsOpen(false);
    }
  };

  const handleQuickSelect = (days: number) => {
    const end = getEndOfDay(new Date());
    const start = getStartOfDay(new Date());
    start.setDate(start.getDate() - days);
    
    setTempStartDate(start);
    setTempEndDate(end);
    onRangeChange(start, end);
    setIsOpen(false);
  };

  const displayText = startDate && endDate
    ? formatDateRange(startDate, endDate)
    : 'Seleccionar rango';

  return (
    <Popover open={isOpen} onOpenChange={setIsOpen}>
      <PopoverTrigger asChild>
        <Button variant="outline" className={`justify-start text-left ${className}`}>
          <Calendar className="w-4 h-4 mr-2" />
          {displayText}
        </Button>
      </PopoverTrigger>
      <PopoverContent className="w-auto p-0" align="start">
        <div className="flex flex-col">
          <div className="p-3 border-b">
            <p className="text-sm font-medium mb-2">
              {selectingStart ? 'Selecciona fecha inicial' : 'Selecciona fecha final'}
            </p>
            <div className="flex flex-wrap gap-2">
              <Button
                variant="outline"
                size="sm"
                onClick={() => handleQuickSelect(0)}
              >
                Hoy
              </Button>
              <Button
                variant="outline"
                size="sm"
                onClick={() => handleQuickSelect(7)}
              >
                Últimos 7 días
              </Button>
              <Button
                variant="outline"
                size="sm"
                onClick={() => handleQuickSelect(30)}
              >
                Últimos 30 días
              </Button>
            </div>
          </div>
          <CalendarComponent
            mode="single"
            selected={selectingStart ? tempStartDate : tempEndDate}
            onSelect={handleDateSelect}
            initialFocus
          />
        </div>
      </PopoverContent>
    </Popover>
  );
}
