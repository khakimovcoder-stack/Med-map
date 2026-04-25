import { Search, X } from 'lucide-react';
import Input from '../ui/Input.jsx';

export default function HospitalSearch({ value, onChange, placeholder }) {
  return (
    <div className="relative">
      <Input
        type="search"
        value={value}
        onChange={(e) => onChange(e.target.value)}
        placeholder={placeholder || "Shifoxona qidirish... (Toshkent, RIKM, Buxoro)"}
        leftIcon={Search}
        className="h-14 text-base shadow-card"
        aria-label="Shifoxona qidirish"
        rightSlot={
          value ? (
            <button
              type="button"
              onClick={() => onChange('')}
              className="rounded-full p-1.5 text-gray-400 transition-colors hover:bg-gray-100 hover:text-gray-700"
              aria-label="Qidiruvni tozalash"
            >
              <X size={16} aria-hidden="true" />
            </button>
          ) : null
        }
      />
    </div>
  );
}
