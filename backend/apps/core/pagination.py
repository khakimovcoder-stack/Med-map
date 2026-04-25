"""Pagination class that emits the contract's paginated envelope."""
from __future__ import annotations

import math
from typing import Any

from rest_framework.pagination import PageNumberPagination
from rest_framework.response import Response

from apps.core.envelope import build_meta


class EnvelopePagination(PageNumberPagination):
    page_size = 20
    page_size_query_param = "page_size"
    max_page_size = 100

    def get_paginated_response(self, data: list[Any]) -> Response:
        request_id = getattr(self.request, "id", None)
        page_size = self.get_page_size(self.request)
        total = self.page.paginator.count
        total_pages = max(1, math.ceil(total / page_size)) if page_size else 1

        envelope = {
            "success": True,
            "data": data,
            "meta": build_meta(
                request_id,
                page=self.page.number,
                page_size=page_size,
                total=total,
                total_pages=total_pages,
            ),
        }
        return Response(envelope)
