#
# Copyright (c) 2023 Airbyte, Inc., all rights reserved.
#

import pytest
import requests
from source_catfact.source import SourceCatfact
from source_catfact.streams import CatFactsStream, CatBreedsStream, SingleCatFactStream


class TestCatFactIntegration:
    """Integration tests for Cat Fact API connector."""

    @pytest.fixture
    def config(self):
        """Basic configuration for testing."""
        return {
            "max_length": 200,
            "limit": 5
        }

    @pytest.fixture
    def source(self):
        """Source instance for testing."""
        return SourceCatfact()

    def test_connection_check(self, source, config):
        """Test that we can successfully connect to the Cat Fact API."""
        logger = pytest.LoggingPlugin().pytest_configure(None)
        success, error = source.check_connection(logger, config)
        
        assert success is True
        assert error is None

    def test_cat_facts_stream_read(self, config):
        """Test reading from cat facts stream."""
        stream = CatFactsStream(config=config)
        
        records = list(stream.read_records(sync_mode=None))
        
        # Should get some records
        assert len(records) > 0
        
        # Check record structure
        for record in records:
            assert "fact" in record
            assert "length" in record
            assert isinstance(record["fact"], str)
            assert isinstance(record["length"], int)
            assert len(record["fact"]) == record["length"]
            
            # Respect max_length config
            if config.get("max_length"):
                assert record["length"] <= config["max_length"]

    def test_cat_breeds_stream_read(self, config):
        """Test reading from cat breeds stream."""
        stream = CatBreedsStream(config=config)
        
        records = list(stream.read_records(sync_mode=None))
        
        # Should get some records
        assert len(records) > 0
        
        # Check record structure
        for record in records:
            # All fields should be present (though some might be empty)
            expected_fields = ["breed", "country", "origin", "coat", "pattern"]
            for field in expected_fields:
                assert field in record

    def test_single_cat_fact_stream_read(self, config):
        """Test reading from single cat fact stream."""
        stream = SingleCatFactStream(config=config)
        
        records = list(stream.read_records(sync_mode=None))
        
        # Should get exactly one record
        assert len(records) == 1
        
        record = records[0]
        assert "fact" in record
        assert "length" in record
        assert isinstance(record["fact"], str)
        assert isinstance(record["length"], int)
        assert len(record["fact"]) == record["length"]

    def test_api_endpoints_accessible(self):
        """Test that all API endpoints are accessible."""
        base_url = "https://catfact.ninja/"
        
        # Test facts endpoint
        response = requests.get(f"{base_url}facts", params={"limit": 1})
        assert response.status_code == 200
        data = response.json()
        assert isinstance(data, list)
        
        # Test breeds endpoint
        response = requests.get(f"{base_url}breeds", params={"limit": 1})
        assert response.status_code == 200
        data = response.json()
        assert isinstance(data, list)
        
        # Test single fact endpoint
        response = requests.get(f"{base_url}fact")
        assert response.status_code == 200
        data = response.json()
        assert "fact" in data
        assert "length" in data

    def test_streams_with_different_configs(self):
        """Test streams with various configuration options."""
        # Test with minimal config
        minimal_config = {}
        stream = CatFactsStream(config=minimal_config)
        records = list(stream.read_records(sync_mode=None))
        assert len(records) > 0
        
        # Test with max_length only
        max_length_config = {"max_length": 50}
        stream = CatFactsStream(config=max_length_config)
        records = list(stream.read_records(sync_mode=None))
        assert len(records) > 0
        for record in records:
            assert record["length"] <= 50
        
        # Test with limit only
        limit_config = {"limit": 3}
        stream = CatFactsStream(config=limit_config)
        records = list(stream.read_records(sync_mode=None))
        # Note: The API might return fewer records than requested
        assert len(records) <= 3

    def test_error_handling(self):
        """Test error handling for invalid requests."""
        # Test with invalid max_length (too large)
        config = {"max_length": 10000}  # Very large value
        stream = CatFactsStream(config=config)
        
        # Should still work, API will handle the constraint
        records = list(stream.read_records(sync_mode=None))
        assert len(records) >= 0  # Might return empty list but shouldn't crash

    @pytest.mark.slow
    def test_large_data_fetch(self):
        """Test fetching larger amounts of data."""
        config = {"limit": 50}  # Request more records
        stream = CatFactsStream(config=config)
        
        records = list(stream.read_records(sync_mode=None))
        
        # Should get some records (API might limit actual returned count)
        assert len(records) > 0
        
        # All records should be valid
        for record in records:
            assert "fact" in record
            assert "length" in record
            assert len(record["fact"]) == record["length"]