import { NavLink } from 'react-router-dom';
import {
  ChevronDown,
  Bed,
  Building2,
  QrCode,
  ClipboardCheck,
  Map,
  BookOpen,
  Layers,
  Smartphone,
  Vote,
  Heart,
  HelpCircle,
  Globe,
} from 'lucide-react';

const SERVICES = [
  { Icon: Bed, label: "Ommabop xizmatlar", to: '/' },
  { Icon: Layers, label: 'Sohalar', to: '#sohalar' },
  { Icon: ClipboardCheck, label: "Xizmatlar uchun to'lov", to: '#tolov' },
  { Icon: ClipboardCheck, label: 'Arizani tekshirish', to: '#ariza' },
  { Icon: Map, label: 'Joylar xaritasi', to: '#xarita' },
  { Icon: BookOpen, label: 'Yagona reyestr', to: '#reyestr' },
  { Icon: Layers, label: 'Proaktiv va kompozit xizmatlar', to: '#proaktiv' },
  { Icon: Smartphone, label: 'Mobil ilovalar', to: '#mobil' },
];

const HELP = [
  { Icon: Vote, label: 'Elektron ishtirok', to: '#ishtirok' },
  { Icon: Heart, label: 'Hayotiy vaziyatlar', to: '#hayotiy' },
  { Icon: HelpCircle, label: "Ko'p beriladigan savollar", to: '#savollar' },
  { Icon: Globe, label: 'Xorij fuqarolari uchun', to: '#xorij' },
];

function Item({ Icon, label, to, end }) {
  const isInternal = to.startsWith('/');
  const cls = ({ isActive }) =>
    `group flex items-center gap-2.5 rounded-md px-3 py-2 text-[13px] transition-colors ${
      isActive
        ? 'bg-white/10 text-white'
        : 'text-white/85 hover:bg-white/10 hover:text-white'
    }`;
  if (isInternal) {
    return (
      <NavLink to={to} end={end} className={cls}>
        <Icon size={15} className="shrink-0 opacity-90" aria-hidden="true" />
        <span className="truncate">{label}</span>
      </NavLink>
    );
  }
  return (
    <a
      href={to}
      className="group flex items-center gap-2.5 rounded-md px-3 py-2 text-[13px] text-white/85 transition-colors hover:bg-white/10 hover:text-white"
    >
      <Icon size={15} className="shrink-0 opacity-90" aria-hidden="true" />
      <span className="truncate">{label}</span>
    </a>
  );
}

export default function Sidebar() {
  return (
    <aside className="hidden w-64 shrink-0 bg-[#1856b2] text-white lg:block">
      <div className="sticky top-0 flex h-screen flex-col">
        {/* Logo block */}
        <div className="flex items-center gap-2.5 border-b border-white/10 px-5 py-4">
          <span className="flex h-9 w-9 items-center justify-center rounded-md bg-white p-0.5">
            <img
              src="/icon.png"
              alt="MED MAP"
              className="h-full w-full object-contain"
            />
          </span>
          <span className="flex flex-col leading-tight">
            <span className="text-[15px] font-bold tracking-wide">MED MAP</span>
            <span className="text-[10px] uppercase tracking-wider text-white/70">
              shaffof shifoxona
            </span>
          </span>
        </div>

        {/* Section: Xizmatlar */}
        <div className="px-3 pt-4">
          <button
            type="button"
            className="flex w-full items-center justify-between rounded-md px-3 py-2 text-[13px] font-bold uppercase tracking-wider text-white"
          >
            <span>Xizmatlar</span>
            <ChevronDown size={14} className="opacity-80" />
          </button>
        </div>
        <nav className="px-3 pt-1">
          {SERVICES.map((it) => (
            <Item key={it.label} {...it} end={it.to === '/'} />
          ))}
        </nav>

        {/* Section: Help */}
        <div className="mt-auto px-3 pb-2 pt-6">
          <div className="mb-1 px-3 text-[13px] font-bold leading-snug">
            Yordam va qo&apos;llab-quvvatlash
          </div>
          <nav>
            {HELP.map((it) => (
              <Item key={it.label} {...it} />
            ))}
          </nav>
        </div>

        {/* Bottom credit */}
        <div className="border-t border-white/10 px-5 py-3 text-[10px] text-white/60">
          © 2026 MED MAP demo
        </div>
      </div>
    </aside>
  );
}
