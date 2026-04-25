import { useQuery } from '@tanstack/react-query';
import { getQrCodes } from '../api/endpoints.js';

export function useQrCodes(hospitalId) {
  return useQuery({
    queryKey: ['qr-codes', hospitalId ?? 'all'],
    queryFn: () => getQrCodes({ hospitalId }),
    staleTime: 5 * 60 * 1000,
  });
}
