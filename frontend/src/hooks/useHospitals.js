import { useQuery } from '@tanstack/react-query';
import { getHospitals } from '../api/endpoints.js';

export function useHospitals({ search = '', city = '' } = {}) {
  return useQuery({
    queryKey: ['hospitals', { search, city }],
    queryFn: () => getHospitals({ search, city }),
  });
}
