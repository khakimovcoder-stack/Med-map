import {
  Phone,
  Bell,
  Accessibility,
  ChevronDown,
  User,
} from 'lucide-react';

export default function Header() {
  return (
    <header className="sticky top-0 z-30 border-b border-govgray-100 bg-white">
      <div className="flex h-16 items-center justify-between gap-4 px-5 lg:px-8">
        {/* Left — gov text on mobile (logo lives in sidebar on desktop) */}
        <div className="flex items-center gap-3 lg:hidden">
          <span className="flex h-9 w-9 items-center justify-center rounded-md bg-[#1856b2] p-0.5">
            <img
              src="/icon.png"
              alt="MED MAP"
              className="h-full w-full object-contain"
            />
          </span>
          <span className="flex flex-col leading-tight">
            <span className="text-[14px] font-bold text-[#1856b2]">MED MAP</span>
            <span className="text-[9px] uppercase tracking-wider text-govgray-500">
              shaffof shifoxona
            </span>
          </span>
        </div>

        {/* Subtitle (gov-style line) */}
        <div className="hidden items-center lg:flex">
          <span className="text-[10px] font-semibold uppercase leading-tight tracking-wider text-govgray-500">
            YAGONA SHAFFOF SHIFOXONA<br />
            DAVLAT XIZMATI
          </span>
        </div>

        {/* Right actions */}
        <div className="ml-auto flex items-center gap-2 sm:gap-4">
          <a
            href="tel:112"
            className="hidden items-center gap-2 sm:flex"
            aria-label="112 SOS"
          >
            <span className="flex h-9 w-9 items-center justify-center rounded-full bg-[#e91e63] text-white">
              <Bell size={16} aria-hidden="true" />
            </span>
            <span className="flex flex-col leading-tight">
              <span className="text-[13px] font-bold text-[#e91e63]">112</span>
              <span className="text-[10px] text-govgray-500">SOS</span>
            </span>
          </a>
          <span className="hidden h-7 w-px bg-govgray-200 sm:inline-block" />
          <a
            href="tel:1175"
            className="hidden items-center gap-2 sm:flex"
            aria-label="1175 Qayta aloqa"
          >
            <span className="flex h-9 w-9 items-center justify-center rounded-full bg-[#1856b2] text-white">
              <Phone size={15} aria-hidden="true" />
            </span>
            <span className="flex flex-col leading-tight">
              <span className="text-[13px] font-bold text-[#1856b2]">1175</span>
              <span className="text-[10px] text-govgray-500">Qayta aloqa</span>
            </span>
          </a>
          <span className="hidden h-7 w-px bg-govgray-200 sm:inline-block" />

          {/* Language */}
          <button
            type="button"
            className="inline-flex items-center gap-1 rounded px-2 py-1 text-[13px] font-medium text-govgray-700 hover:bg-govgray-50"
            aria-label="Tilni tanlash"
          >
            <span>O&apos;z</span>
            <ChevronDown size={13} aria-hidden="true" />
          </button>

          {/* Accessibility */}
          <button
            type="button"
            className="hidden h-9 w-9 items-center justify-center rounded-full text-govgray-700 hover:bg-govgray-50 sm:inline-flex"
            aria-label="Maxsus imkoniyatlar"
          >
            <Accessibility size={18} aria-hidden="true" />
          </button>

          {/* Personal cabinet */}
          <button
            type="button"
            className="inline-flex h-10 items-center gap-2 rounded-full bg-[#1856b2] px-4 text-[13px] font-semibold text-white hover:bg-[#0f4690]"
          >
            <User size={15} aria-hidden="true" />
            <span className="hidden sm:inline">Shaxsiy kabinet</span>
            <span className="sm:hidden">Kirish</span>
          </button>
        </div>
      </div>
    </header>
  );
}
