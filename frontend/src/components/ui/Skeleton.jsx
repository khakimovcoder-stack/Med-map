import clsx from 'clsx';

export default function Skeleton({ className, as: As = 'div', ...rest }) {
  return <As className={clsx('skeleton', className)} {...rest} />;
}
