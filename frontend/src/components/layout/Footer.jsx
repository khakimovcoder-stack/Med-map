import {
  Phone,
  Mail,
  MapPin,
  ShieldCheck,
  ExternalLink,
  Apple,
  Smartphone,
} from 'lucide-react';
import Container from './Container.jsx';


const navLinks = [
  { label: 'Bosh sahifa', href: '/' },
  { label: 'QR Simulyator', href: '/qr-simulator' },
  { label: 'OneID orqali kirish', href: '#oneid' },
  { label: 'Foydalanish shartlari', href: '#terms' },
];

const govLinks = [
  { label: 'my.gov.uz', href: 'https://my.gov.uz' },
  { label: 'Sog\'liqni saqlash vazirligi', href: 'https://minzdrav.uz' },
  { label: 'OneID identifikatsiyasi', href: 'https://id.egov.uz' },
  { label: 'Ishonch telefoni: 1175', href: 'tel:1175' },
];

export default function Footer() {
  return (
    <footer className="mt-16 border-t-4 border-gov-600 bg-gov-900 text-gov-100">
      <Container className="grid gap-10 py-12 md:grid-cols-12">
        {/* Brand column */}
        <div className="md:col-span-4">
          <div className="flex items-center gap-3">
            <span className="flex h-11 w-11 items-center justify-center rounded-md bg-white p-1 ring-1 ring-white/20">
              <img src="/icon.png" alt="Med Map" className="h-full w-full object-contain" />
            </span>
            <div className="flex flex-col leading-tight">
              <span className="text-[10px] font-semibold uppercase tracking-[0.18em] text-gov-300">
                Davlat xizmati
              </span>
              <span className="text-lg font-bold tracking-wide text-white">MED MAP</span>
            </div>
          </div>
          <p className="mt-4 text-sm leading-relaxed text-gov-200">
            Shifoxonalardagi karavotlar mavjudligini bemorlarning o&apos;zi
            tasdiqlaydigan jamoatchilik nazorati platformasi. Antikorrupsiya
            tashabbusi doirasida ishlab chiqilgan.
          </p>
          <div className="mt-5 flex items-center gap-2 rounded border border-white/10 bg-white/5 px-3 py-2 text-xs text-gov-100">
            <ShieldCheck size={14} className="text-success-500" />
            <span>OneID orqali identifikatsiya • Davlat standartlari</span>
          </div>
        </div>

        {/* Links columns */}
        <div className="md:col-span-2">
          <h3 className="mb-3 text-xs font-bold uppercase tracking-wider text-gov-300">
            Loyiha
          </h3>
          <ul className="space-y-2 text-sm">
            {navLinks.map((l) => (
              <li key={l.href}>
                <a href={l.href} className="text-gov-100 hover:text-white">
                  {l.label}
                </a>
              </li>
            ))}
          </ul>
        </div>

        <div className="md:col-span-3">
          <h3 className="mb-3 text-xs font-bold uppercase tracking-wider text-gov-300">
            Davlat resurslari
          </h3>
          <ul className="space-y-2 text-sm">
            {govLinks.map((l) => (
              <li key={l.href}>
                <a
                  href={l.href}
                  target="_blank"
                  rel="noopener noreferrer"
                  className="inline-flex items-center gap-1.5 text-gov-100 hover:text-white"
                >
                  {l.label}
                  <ExternalLink size={11} className="opacity-60" />
                </a>
              </li>
            ))}
          </ul>
        </div>

        <div className="md:col-span-3">
          <h3 className="mb-3 text-xs font-bold uppercase tracking-wider text-gov-300">
            Aloqa
          </h3>
          <ul className="space-y-3 text-sm">
            <li className="flex items-start gap-2">
              <MapPin size={14} className="mt-0.5 text-gov-300" />
              <span>Toshkent sh., A. Navoiy 12-uy</span>
            </li>
            <li className="flex items-center gap-2">
              <Phone size={14} className="text-gov-300" />
              <a href="tel:1175" className="hover:text-white">1175 (24/7)</a>
            </li>
            <li className="flex items-center gap-2">
              <Mail size={14} className="text-gov-300" />
              <a href="mailto:info@medmap.uz" className="hover:text-white">
                info@medmap.uz
              </a>
            </li>
          </ul>
          <div className="mt-5">
            <p className="mb-2 text-xs font-semibold text-gov-300">Mobil ilova</p>
            <div className="flex gap-2">
              <a
                href="#android"
                className="inline-flex items-center gap-1.5 rounded border border-white/15 bg-white/5 px-3 py-1.5 text-xs text-gov-100 hover:bg-white/10"
              >
                <Smartphone size={14} />
                Android
              </a>
              <a
                href="#ios"
                className="inline-flex items-center gap-1.5 rounded border border-white/15 bg-white/5 px-3 py-1.5 text-xs text-gov-100 hover:bg-white/10"
              >
                <Apple size={14} />
                iOS
              </a>
            </div>
          </div>
        </div>
      </Container>

      <div className="border-t border-white/10 bg-gov-900">
        <Container className="flex flex-col items-center justify-between gap-2 py-4 text-xs text-gov-300 sm:flex-row">
          <p>
            &copy; 2026 Med Map. Barcha huquqlar himoyalangan.
          </p>
          <p>
            Antikorrupsiya xakatoni 2026 &middot; Demo rejim
          </p>
        </Container>
      </div>
    </footer>
  );
}
