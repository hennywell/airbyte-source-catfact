#
# Copyright (c) 2023 Airbyte, Inc., all rights reserved.
#

from typing import Any, Iterable, Mapping, Optional
import requests

from airbyte_cdk.sources.streams.http import HttpStream


class CatFactApiStream(HttpStream):
    """
    Base class for Cat Fact API streams.
    """
    
    url_base = "https://catfact.ninja/"
    primary_key = None
    
    def __init__(self, config: Mapping[str, Any], **kwargs):
        super().__init__(**kwargs)
        self.config = config

    def next_page_token(self, response: requests.Response) -> Optional[Mapping[str, Any]]:
        """
        Handle pagination for Cat Fact API.
        """
        json_response = response.json()
        next_page_url = json_response.get("next_page_url")
        if next_page_url:
            # Extract page number from URL
            import re
            page_match = re.search(r'page=(\d+)', next_page_url)
            if page_match:
                return {"page": int(page_match.group(1))}
        return None

    def request_params(
        self,
        stream_state: Optional[Mapping[str, Any]] = None,
        stream_slice: Optional[Mapping[str, Any]] = None,
        next_page_token: Optional[Mapping[str, Any]] = None,
    ) -> Mapping[str, Any]:
        """
        Base request parameters.
        """
        params = {}
        
        # Add limit if specified in config
        if self.config.get("limit"):
            params["limit"] = self.config["limit"]
        
        # Add page number for pagination
        if next_page_token:
            params["page"] = next_page_token["page"]
            
        return params

    def parse_response(self, response: requests.Response, **kwargs) -> Iterable[Mapping[str, Any]]:
        """
        Parse the response from the API.
        """
        json_response = response.json()
        
        # Handle different response structures
        if isinstance(json_response, list):
            yield from json_response
        elif isinstance(json_response, dict):
            # For single fact endpoint
            if "fact" in json_response:
                yield json_response
            # For paginated endpoints that return data in a wrapper
            elif "data" in json_response:
                data = json_response["data"]
                if isinstance(data, list):
                    yield from data
                else:
                    yield data
            else:
                yield json_response


class CatFactsStream(CatFactApiStream):
    """
    Stream for retrieving cat facts from /facts endpoint.
    """
    
    def path(
        self,
        stream_state: Optional[Mapping[str, Any]] = None,
        stream_slice: Optional[Mapping[str, Any]] = None,
        next_page_token: Optional[Mapping[str, Any]] = None,
    ) -> str:
        return "facts"

    def request_params(
        self,
        stream_state: Optional[Mapping[str, Any]] = None,
        stream_slice: Optional[Mapping[str, Any]] = None,
        next_page_token: Optional[Mapping[str, Any]] = None,
    ) -> Mapping[str, Any]:
        """
        Request parameters for facts endpoint.
        """
        params = dict(super().request_params(stream_state, stream_slice, next_page_token))
        
        # Add max_length if specified in config
        if self.config.get("max_length"):
            params["max_length"] = self.config["max_length"]
            
        return params

    def get_json_schema(self) -> Mapping[str, Any]:
        """
        JSON schema for cat facts.
        """
        return {
            "$schema": "http://json-schema.org/draft-07/schema#",
            "type": "object",
            "properties": {
                "fact": {
                    "type": "string",
                    "description": "The cat fact text"
                },
                "length": {
                    "type": "integer",
                    "description": "The length of the fact in characters"
                }
            }
        }


class CatBreedsStream(CatFactApiStream):
    """
    Stream for retrieving cat breeds from /breeds endpoint.
    """
    
    def path(
        self,
        stream_state: Optional[Mapping[str, Any]] = None,
        stream_slice: Optional[Mapping[str, Any]] = None,
        next_page_token: Optional[Mapping[str, Any]] = None,
    ) -> str:
        return "breeds"

    def get_json_schema(self) -> Mapping[str, Any]:
        """
        JSON schema for cat breeds.
        """
        return {
            "$schema": "http://json-schema.org/draft-07/schema#",
            "type": "object",
            "properties": {
                "breed": {
                    "type": "string",
                    "description": "The breed name"
                },
                "country": {
                    "type": "string",
                    "description": "The country of origin"
                },
                "origin": {
                    "type": "string",
                    "description": "The origin description"
                },
                "coat": {
                    "type": "string",
                    "description": "The coat type"
                },
                "pattern": {
                    "type": "string",
                    "description": "The coat pattern"
                }
            }
        }


class SingleCatFactStream(CatFactApiStream):
    """
    Stream for retrieving a single random cat fact from /fact endpoint.
    """
    
    def path(
        self,
        stream_state: Optional[Mapping[str, Any]] = None,
        stream_slice: Optional[Mapping[str, Any]] = None,
        next_page_token: Optional[Mapping[str, Any]] = None,
    ) -> str:
        return "fact"

    def request_params(
        self,
        stream_state: Optional[Mapping[str, Any]] = None,
        stream_slice: Optional[Mapping[str, Any]] = None,
        next_page_token: Optional[Mapping[str, Any]] = None,
    ) -> Mapping[str, Any]:
        """
        Request parameters for single fact endpoint.
        """
        params = {}
        
        # Add max_length if specified in config
        if self.config.get("max_length"):
            params["max_length"] = self.config["max_length"]
            
        return params

    def get_json_schema(self) -> Mapping[str, Any]:
        """
        JSON schema for single cat fact.
        """
        return {
            "$schema": "http://json-schema.org/draft-07/schema#",
            "type": "object",
            "properties": {
                "fact": {
                    "type": "string",
                    "description": "The cat fact text"
                },
                "length": {
                    "type": "integer",
                    "description": "The length of the fact in characters"
                }
            }
        }