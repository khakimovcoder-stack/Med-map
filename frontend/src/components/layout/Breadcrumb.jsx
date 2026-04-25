import { Link } from 'react-router-dom';
import { ChevronRight } from 'lucide-react';

export default function Breadcrumb({ items = [] }) {
  if (!items.length) return null;
  return (
    <nav aria-label="Breadcrumb" className="mb-4">
      <ol className="flex flex-wrap items-center gap-1.5 text-sm text-gray-500">
        {items.map((item, idx) => {
          const isLast = idx === items.length - 1;
          return (
            <li key={`${item.label}-${idx}`} className="flex items-center gap-1.5">
              {item.to && !isLast ? (
                <Link
                  to={item.to}
                  className="font-medium text-gray-600 transition-colors hover:text-brand-blue-800"
                >
                  {item.label}
                </Link>
              ) : (
                <span className={isLast ? 'font-semibold text-gray-900' : 'text-gray-600'}>
                  {item.label}
                </span>
              )}
              {!isLast && <ChevronRight size={14} className="text-gray-400" aria-hidden="true" />}
            </li>
          );
        })}
      </ol>
    </nav>
  );
}
