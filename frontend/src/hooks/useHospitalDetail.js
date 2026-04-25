import { useQuery } from '@tanstack/react-query';
import { getHospital } from '../api/endpoints.js';

export function useHospitalDetail(id) {
  return useQuery({
    queryKey: ['hospital', id],
    queryFn: () => getHospital(id),
    enabled: Boolean(id),
  });
}
