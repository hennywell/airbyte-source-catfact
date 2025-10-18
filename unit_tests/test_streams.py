#
# Copyright (c) 2023 Airbyte, Inc., all rights reserved.
#

import pytest
import requests
from unittest.mock import Mock
from source_catfact.streams import CatFactsStream, CatBreedsStream, SingleCatFactStream


class TestCatFactsStream:
    """Test cases for CatFactsStream."""

    def test_path(self):
        """Test that path returns correct endpoint."""
        stream = CatFactsStream(config={})
        assert stream.path() == "facts"

    def test_request_params_with_config(self):
        """Test request parameters with configuration."""
        config = {"max_length": 100, "limit": 10}
        stream = CatFactsStream(config=config)
        
        params = stream.request_params()
        
        assert params["max_length"] == 100
        assert params["limit"] == 10

    def test_request_params_empty_config(self):
        """Test request parameters with empty configuration."""
        stream = CatFactsStream(config={})
        
        params = stream.request_params()
        
        assert params == {}

    def test_parse_response_list(self):
        """Test parsing response with list of facts."""
        stream = CatFactsStream(config={})
        
        mock_response = Mock(spec=requests.Response)
        mock_response.json.return_value = [
            {"fact": "Cats are great", "length": 14},
            {"fact": "Dogs are also great", "length": 19}
        ]
        
        records = list(stream.parse_response(mock_response))
        
        assert len(records) == 2
        assert records[0]["fact"] == "Cats are great"
        assert records[1]["fact"] == "Dogs are also great"

    def test_parse_response_single_fact(self):
        """Test parsing response with single fact."""
        stream = CatFactsStream(config={})
        
        mock_response = Mock(spec=requests.Response)
        mock_response.json.return_value = {"fact": "Cats are amazing", "length": 16}
        
        records = list(stream.parse_response(mock_response))
        
        assert len(records) == 1
        assert records[0]["fact"] == "Cats are amazing"

    def test_get_json_schema(self):
        """Test JSON schema for cat facts."""
        stream = CatFactsStream(config={})
        schema = stream.get_json_schema()
        
        assert schema["type"] == "object"
        assert "fact" in schema["properties"]
        assert "length" in schema["properties"]
        assert schema["properties"]["fact"]["type"] == "string"
        assert schema["properties"]["length"]["type"] == "integer"


class TestCatBreedsStream:
    """Test cases for CatBreedsStream."""

    def test_path(self):
        """Test that path returns correct endpoint."""
        stream = CatBreedsStream(config={})
        assert stream.path() == "breeds"

    def test_parse_response(self):
        """Test parsing response with breed data."""
        stream = CatBreedsStream(config={})
        
        mock_response = Mock(spec=requests.Response)
        mock_response.json.return_value = [
            {
                "breed": "Persian",
                "country": "Iran",
                "origin": "Iran",
                "coat": "Long",
                "pattern": "Solid"
            }
        ]
        
        records = list(stream.parse_response(mock_response))
        
        assert len(records) == 1
        assert records[0]["breed"] == "Persian"
        assert records[0]["country"] == "Iran"

    def test_get_json_schema(self):
        """Test JSON schema for cat breeds."""
        stream = CatBreedsStream(config={})
        schema = stream.get_json_schema()
        
        assert schema["type"] == "object"
        expected_fields = ["breed", "country", "origin", "coat", "pattern"]
        for field in expected_fields:
            assert field in schema["properties"]
            assert schema["properties"][field]["type"] == "string"


class TestSingleCatFactStream:
    """Test cases for SingleCatFactStream."""

    def test_path(self):
        """Test that path returns correct endpoint."""
        stream = SingleCatFactStream(config={})
        assert stream.path() == "fact"

    def test_request_params_with_max_length(self):
        """Test request parameters with max_length."""
        config = {"max_length": 50}
        stream = SingleCatFactStream(config=config)
        
        params = stream.request_params()
        
        assert params["max_length"] == 50

    def test_request_params_no_max_length(self):
        """Test request parameters without max_length."""
        stream = SingleCatFactStream(config={})
        
        params = stream.request_params()
        
        assert params == {}

    def test_get_json_schema(self):
        """Test JSON schema for single cat fact."""
        stream = SingleCatFactStream(config={})
        schema = stream.get_json_schema()
        
        assert schema["type"] == "object"
        assert "fact" in schema["properties"]
        assert "length" in schema["properties"]


class TestCatFactApiStream:
    """Test cases for base CatFactApiStream functionality."""

    def test_url_base(self):
        """Test that URL base is correct."""
        stream = CatFactsStream(config={})
        assert stream.url_base == "https://catfact.ninja/"

    def test_next_page_token_returns_none(self):
        """Test that next_page_token returns None when no next page."""
        stream = CatFactsStream(config={})
        mock_response = Mock(spec=requests.Response)
        mock_response.json.return_value = {"next_page_url": None}
        
        token = stream.next_page_token(mock_response)
        
        assert token is None

    def test_next_page_token_with_pagination(self):
        """Test that next_page_token extracts page number correctly."""
        stream = CatFactsStream(config={})
        mock_response = Mock(spec=requests.Response)
        mock_response.json.return_value = {"next_page_url": "https://catfact.ninja/facts?page=2"}
        
        token = stream.next_page_token(mock_response)
        
        assert token == {"page": 2}