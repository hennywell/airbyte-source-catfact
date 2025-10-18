#
# Copyright (c) 2023 Airbyte, Inc., all rights reserved.
#

from typing import Any, List, Mapping, Tuple
import logging

from airbyte_cdk.sources import AbstractSource
from airbyte_cdk.sources.streams import Stream
from airbyte_cdk.sources.streams.http.requests_native_auth import TokenAuthenticator

from .streams import CatFactsStream, CatBreedsStream


class SourceCatfact(AbstractSource):
    """
    Source implementation for Cat Fact API.
    
    This source connector retrieves data from the Cat Fact API (catfact.ninja)
    which provides cat facts and breed information without requiring authentication.
    """

    def check_connection(self, logger: logging.Logger, config: Mapping[str, Any]) -> Tuple[bool, Any]:
        """
        Check if we can connect to the Cat Fact API.
        
        Args:
            logger: Logger instance
            config: Configuration mapping
            
        Returns:
            Tuple of (success: bool, error_message: Any)
        """
        try:
            # Test connection by trying to fetch a single fact
            test_stream = CatFactsStream(config=config)
            
            # Try to read one record to verify the API is accessible
            records = test_stream.read_records(sync_mode=None)
            next(records)  # Try to get the first record
            
            logger.info("Successfully connected to Cat Fact API")
            return True, None
            
        except Exception as e:
            logger.error(f"Failed to connect to Cat Fact API: {str(e)}")
            return False, f"Connection failed: {str(e)}"

    def streams(self, config: Mapping[str, Any]) -> List[Stream]:
        """
        Return a list of streams for this source.
        
        Args:
            config: Configuration mapping
            
        Returns:
            List of Stream instances
        """
        return [
            CatFactsStream(config=config),
            CatBreedsStream(config=config),
        ]