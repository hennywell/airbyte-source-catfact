#
# Copyright (c) 2023 Airbyte, Inc., all rights reserved.
#

import pytest
from unittest.mock import Mock, patch
from source_catfact.source import SourceCatfact


class TestSourceCatfact:
    """Test cases for SourceCatfact class."""

    def test_check_connection_success(self):
        """Test successful connection check."""
        source = SourceCatfact()
        logger = Mock()
        config = {"max_length": 100, "limit": 10}
        
        # Mock the stream's read_records method to return a successful response
        with patch('source_catfact.source.CatFactsStream') as mock_stream_class:
            mock_stream = Mock()
            mock_stream.read_records.return_value = iter([{"fact": "Test fact", "length": 9}])
            mock_stream_class.return_value = mock_stream
            
            success, error = source.check_connection(logger, config)
            
            assert success is True
            assert error is None
            logger.info.assert_called_with("Successfully connected to Cat Fact API")

    def test_check_connection_failure(self):
        """Test failed connection check."""
        source = SourceCatfact()
        logger = Mock()
        config = {"max_length": 100, "limit": 10}
        
        # Mock the stream to raise an exception
        with patch('source_catfact.source.CatFactsStream') as mock_stream_class:
            mock_stream = Mock()
            mock_stream.read_records.side_effect = Exception("API Error")
            mock_stream_class.return_value = mock_stream
            
            success, error = source.check_connection(logger, config)
            
            assert success is False
            assert "Connection failed: API Error" in str(error)
            logger.error.assert_called()

    def test_streams(self):
        """Test that streams method returns expected streams."""
        source = SourceCatfact()
        config = {"max_length": 100, "limit": 10}
        
        streams = source.streams(config)
        
        assert len(streams) == 2
        stream_names = [stream.__class__.__name__ for stream in streams]
        assert "CatFactsStream" in stream_names
        assert "CatBreedsStream" in stream_names

    def test_streams_with_empty_config(self):
        """Test streams method with empty config."""
        source = SourceCatfact()
        config = {}
        
        streams = source.streams(config)
        
        assert len(streams) == 2
        # Verify that streams can be instantiated with empty config
        for stream in streams:
            assert stream.config == config