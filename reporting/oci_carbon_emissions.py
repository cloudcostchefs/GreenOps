#!/usr/bin/env python3
"""
OCI Carbon Emissions Data Retrieval Script

This script retrieves carbon emissions data from Oracle Cloud Infrastructure (OCI)
using the Usage API. It supports various filtering options and output formats.

Requirements:
- oci SDK: pip install oci
- Proper OCI configuration file or environment variables set up

Usage:
    python oci_carbon_emissions.py --help
"""

import argparse
import csv
import json
import os
import sys
from datetime import datetime, timedelta
from typing import Dict, List, Optional

import oci
from oci.config import from_file
from oci.usage_api import UsageapiClient
from oci.usage_api.models import RequestUsageCarbonEmissionsDetails


class OCICarbonEmissionsRetriever:
    """Class to handle OCI carbon emissions data retrieval."""
    
    def __init__(self, config_file: Optional[str] = None, profile: str = "DEFAULT"):
        """
        Initialize the OCI client.
        
        Args:
            config_file: Path to OCI config file. If None, uses default location.
            profile: Profile name in config file to use.
        """
        try:
            if config_file:
                self.config = from_file(config_file, profile)
            else:
                self.config = from_file(profile_name=profile)
                
            self.usage_client = UsageapiClient(self.config)
            self.tenant_id = self.config['tenancy']
            
        except Exception as e:
            print(f"Error initializing OCI client: {e}")
            print("Please ensure your OCI configuration is set up correctly.")
            sys.exit(1)
    
    def get_carbon_emissions(
        self,
        start_date: str,
        end_date: str,
        emission_type: str = "LOCATION_BASED",
        calculation_method: str = "POWER_BASED",
        granularity: str = "MONTHLY",
        group_by: Optional[List[str]] = None,
        filters: Optional[Dict] = None,
        compartment_depth: Optional[int] = None,
        is_aggregate_by_time: bool = False,
        limit: Optional[int] = None,
        compartment_ids: Optional[List[str]] = None
    ) -> Dict:
        """
        Retrieve carbon emissions data from OCI.
        
        Args:
            start_date: Start date in ISO format (YYYY-MM-DD or YYYY-MM-DDTHH:mm:ssZ)
            end_date: End date in ISO format (YYYY-MM-DD or YYYY-MM-DDTHH:mm:ssZ)
            emission_type: "LOCATION_BASED" or "MARKET_BASED"
            calculation_method: "POWER_BASED" or "SPEND_BASED"
            granularity: "DAILY" or "MONTHLY"
            group_by: List of fields to group by (e.g., ["service", "region"])
            filters: Dictionary of filters to apply
            compartment_depth: Compartment depth level
            is_aggregate_by_time: Whether to aggregate by time
            limit: Maximum number of items to return
            compartment_ids: List of specific compartment IDs to filter by
            
        Returns:
            Dictionary containing the carbon emissions data
        """
        
        # Ensure dates are in proper format and are first day of month
        start_datetime = self._parse_and_validate_datetime(start_date)
        end_datetime = self._parse_and_validate_datetime(end_date)
        
        # Set default group_by if not provided
        if group_by is None:
            group_by = ["service"]
        
        # Add compartment filter if specified
        if compartment_ids:
            if filters is None:
                filters = {}
            filters['compartmentId'] = compartment_ids
        
        try:
            # Create the request details
            request_details = RequestUsageCarbonEmissionsDetails(
                tenant_id=self.tenant_id,
                time_usage_started=start_datetime,
                time_usage_ended=end_datetime,
                emission_type=emission_type,
                emission_calculation_method=calculation_method,
                granularity=granularity,
                group_by=group_by,
                filter=filters,
                compartment_depth=compartment_depth,
                is_aggregate_by_time=is_aggregate_by_time
            )
            
            # Validate limit parameter
            if limit is not None and limit > 500:
                print(f"Warning: Limit {limit} exceeds maximum allowed (500). Setting to 500.")
                limit = 500
            elif limit is not None and limit <= 0:
                print(f"Warning: Invalid limit {limit}. Setting to None (no limit).")
                limit = None

            # Make the API call
            print(f"Requesting carbon emissions data from {start_date} to {end_date}...")
            response = self.usage_client.request_usage_carbon_emissions(
                request_usage_carbon_emissions_details=request_details,
                limit=limit
            )
            
            return response.data
            
        except Exception as e:
            print(f"Error retrieving carbon emissions data: {e}")
            raise
    
    def _parse_and_validate_datetime(self, date_str: str) -> str:
        """
        Parse and format datetime string for OCI API, ensuring it's the first day of the month.
        
        Args:
            date_str: Date string in various formats
            
        Returns:
            Properly formatted datetime string for OCI API (first day of month)
        """
        try:
            # Try parsing different date formats
            if 'T' in date_str:
                # Already in ISO format - parse and adjust to first day of month
                dt = datetime.fromisoformat(date_str.replace('Z', '+00:00'))
            else:
                # Date only format
                dt = datetime.strptime(date_str, "%Y-%m-%d")
            
            # Ensure it's the first day of the month
            dt = dt.replace(day=1, hour=0, minute=0, second=0, microsecond=0)
            return dt.strftime("%Y-%m-%dT00:00:00Z")
                
        except ValueError as e:
            print(f"Error parsing date '{date_str}': {e}")
            print("Please use format: YYYY-MM-DD or YYYY-MM-DDTHH:mm:ssZ")
            raise
    
    def save_to_csv(self, data: Dict, filename: str) -> None:
        """
        Save carbon emissions data to CSV file.
        
        Args:
            data: Carbon emissions data from API
            filename: Output CSV filename
        """
        if not data.items:
            print("No data to save.")
            return
            
        try:
            # Define the fields we want to export - only include fields that have data
            fieldnames = [
                'compartment_name', 'service', 'resource_name', 'resource_id', 
                'region', 'ad', 'sku_part_number', 'sku_name', 'platform',
                'time_usage_started', 'time_usage_ended', 'computed_carbon_emission',
                'emission_calculation_method', 'emission_type', 'subscription_id', 'tags'
            ]
            
            # Only add tenant fields if they have data
            sample_item = data.items[0] if data.items else None
            if sample_item:
                if getattr(sample_item, 'tenant_id', None):
                    fieldnames.insert(0, 'tenant_id')
                if getattr(sample_item, 'tenant_name', None):
                    fieldnames.insert(1, 'tenant_name')
                if getattr(sample_item, 'compartment_id', None):
                    fieldnames.insert(2, 'compartment_id')
                if getattr(sample_item, 'compartment_path', None):
                    fieldnames.insert(3, 'compartment_path')
            
            with open(filename, 'w', newline='', encoding='utf-8') as csvfile:
                writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
                writer.writeheader()
                
                for item in data.items:
                    row = {}
                    for field in fieldnames:
                        value = getattr(item, field, None)
                        
                        # Handle None values first
                        if value is None:
                            row[field] = ''
                        # Handle datetime objects
                        elif hasattr(value, 'strftime'):
                            row[field] = value.strftime('%Y-%m-%d %H:%M:%S')
                        # Handle tags (list of Tag objects)
                        elif field == 'tags' and value:
                            tag_strings = []
                            if isinstance(value, list):
                                for tag in value:
                                    if hasattr(tag, 'namespace') and hasattr(tag, 'key') and hasattr(tag, 'value'):
                                        if tag.namespace and tag.key and tag.value:
                                            tag_strings.append(f"{tag.namespace}:{tag.key}={tag.value}")
                            row[field] = '; '.join(tag_strings) if tag_strings else ''
                        # Handle other nested objects
                        elif hasattr(value, '__dict__'):
                            row[field] = str(value)
                        # Handle regular values
                        else:
                            row[field] = str(value) if value is not None else ''
                    
                    writer.writerow(row)
                    
            print(f"Data saved to {filename}")
            
        except Exception as e:
            print(f"Error saving to CSV: {e}")
            import traceback
            traceback.print_exc()
            raise
    
    def save_to_json(self, data: Dict, filename: str) -> None:
        """
        Save carbon emissions data to JSON file.
        
        Args:
            data: Carbon emissions data from API
            filename: Output JSON filename
        """
        try:
            # Define the fields we want to export
            fields_to_export = [
                'tenant_id', 'tenant_name', 'compartment_id', 'compartment_path', 
                'compartment_name', 'service', 'resource_name', 'resource_id', 
                'region', 'ad', 'sku_part_number', 'sku_name', 'platform',
                'time_usage_started', 'time_usage_ended', 'computed_carbon_emission',
                'emission_calculation_method', 'emission_type', 'subscription_id', 'tags'
            ]
            
            # Convert OCI response to dictionary
            result = {
                'items': [],
                'metadata': {
                    'request_id': getattr(data, 'opc_request_id', None),
                    'next_page': getattr(data, 'opc_next_page', None),
                    'total_items': len(data.items) if data.items else 0
                }
            }
            
            if data.items:
                for item in data.items:
                    item_dict = {}
                    for field in fields_to_export:
                        value = getattr(item, field, None)
                        
                        # Handle None values first
                        if value is None:
                            item_dict[field] = None
                        # Convert datetime objects to strings
                        elif hasattr(value, 'strftime'):
                            item_dict[field] = value.strftime('%Y-%m-%d %H:%M:%S')
                        # Handle tags (list of Tag objects)
                        elif field == 'tags' and value:
                            tag_list = []
                            for tag in value:
                                if hasattr(tag, 'namespace') and hasattr(tag, 'key') and hasattr(tag, 'value'):
                                    tag_dict = {
                                        'namespace': tag.namespace,
                                        'key': tag.key,
                                        'value': tag.value
                                    }
                                    tag_list.append(tag_dict)
                            item_dict[field] = tag_list
                        else:
                            item_dict[field] = value
                    
                    result['items'].append(item_dict)
            
            with open(filename, 'w', encoding='utf-8') as jsonfile:
                json.dump(result, jsonfile, indent=2, default=str)
                
            print(f"Data saved to {filename}")
            
        except Exception as e:
            print(f"Error saving to JSON: {e}")
            raise
    
    def print_summary(self, data: Dict, group_by_compartments: bool = False) -> None:
        """
        Print a summary of the carbon emissions data.
        
        Args:
            data: Carbon emissions data from API
            group_by_compartments: Whether to show compartment-based breakdown
        """
        if not data.items:
            print("No carbon emissions data found for the specified criteria.")
            return
        
        print("\n" + "="*60)
        print("CARBON EMISSIONS SUMMARY")
        print("="*60)
        
        total_emissions = 0
        service_emissions = {}
        compartment_emissions = {}
        
        for item in data.items:
            emissions = float(item.computed_carbon_emission or 0)
            total_emissions += emissions
            
            # Group by service - add error handling
            try:
                service = getattr(item, 'service', 'Unknown')
                if service is None:
                    service = 'Unknown'
                service = str(service)  # Ensure it's a string
                
                if service in service_emissions:
                    service_emissions[service] += emissions
                else:
                    service_emissions[service] = emissions
            except Exception as e:
                print(f"Warning: Error processing service for item: {e}")
                service = 'Unknown'
                if service in service_emissions:
                    service_emissions[service] += emissions
                else:
                    service_emissions[service] = emissions
            
            # Group by compartment if requested
            if group_by_compartments:
                try:
                    compartment_name = getattr(item, 'compartment_name', None)
                    compartment_id = getattr(item, 'compartment_id', None)
                    
                    # Use compartment name if available, otherwise use ID, otherwise "Root"
                    compartment_key = compartment_name or compartment_id or "Root/Tenancy"
                    if compartment_key is None:
                        compartment_key = "Root/Tenancy"
                    compartment_key = str(compartment_key)  # Ensure it's a string
                    
                    if compartment_key in compartment_emissions:
                        compartment_emissions[compartment_key] += emissions
                    else:
                        compartment_emissions[compartment_key] = emissions
                except Exception as e:
                    print(f"Warning: Error processing compartment for item: {e}")
                    compartment_key = "Unknown"
                    if compartment_key in compartment_emissions:
                        compartment_emissions[compartment_key] += emissions
                    else:
                        compartment_emissions[compartment_key] = emissions
        
        print(f"Total Carbon Emissions: {total_emissions:.6f} MTCO2e")
        print(f"Number of Records: {len(data.items)}")
        
        if group_by_compartments and compartment_emissions:
            print("\nEmissions by Compartment:")
            print("-" * 50)
            for compartment, emissions in sorted(compartment_emissions.items(), 
                                            key=lambda x: x[1], reverse=True):
                try:
                    percentage = (emissions / total_emissions * 100) if total_emissions > 0 else 0
                    compartment_str = str(compartment) if compartment is not None else "Unknown"
                    print(f"{compartment_str[:35]:35}: {emissions:10.6f} MTCO2e ({percentage:5.1f}%)")
                except Exception as e:
                    print(f"Warning: Error formatting compartment '{compartment}': {e}")
        
        if service_emissions:
            print("\nEmissions by Service:")
            print("-" * 40)
            for service, emissions in sorted(service_emissions.items(), 
                                        key=lambda x: x[1], reverse=True):
                try:
                    percentage = (emissions / total_emissions * 100) if total_emissions > 0 else 0
                    service_str = str(service) if service is not None else "Unknown"
                    print(f"{service_str[:25]:25}: {emissions:10.6f} MTCO2e ({percentage:5.1f}%)")
                except Exception as e:
                    print(f"Warning: Error formatting service '{service}': {e}")
                    print(f"Service type: {type(service)}, Value: {repr(service)}")
    
    def debug_api_response(self, data: Dict) -> None:
        """Debug function to inspect API response structure."""
        print("\n" + "="*60)
        print("API RESPONSE DEBUG INFO")
        print("="*60)
        
        print(f"Response type: {type(data)}")
        print(f"Has items: {hasattr(data, 'items')}")
        
        if hasattr(data, 'items') and data.items:
            print(f"Number of items: {len(data.items)}")
            print(f"First item type: {type(data.items[0])}")
            
            # Check first item attributes
            first_item = data.items[0]
            print(f"\nFirst item attributes:")
            for attr in sorted(dir(first_item)):
                if not attr.startswith('_'):
                    try:
                        value = getattr(first_item, attr)
                        if not callable(value):
                            print(f"  {attr}: {repr(value)} (type: {type(value).__name__})")
                    except Exception as e:
                        print(f"  {attr}: Error getting value - {e}")
    
    def get_compartment_list(self) -> List[Dict]:
        """
        Get a list of all compartments in the tenancy.
        
        Returns:
            List of compartment dictionaries with id, name, and path
        """
        try:
            from oci.identity import IdentityClient
            
            identity_client = IdentityClient(self.config)
            
            print("Retrieving compartment list...")
            compartments = []
            
            # Get all compartments in the tenancy
            list_compartments_response = identity_client.list_compartments(
                compartment_id=self.tenant_id,
                compartment_id_in_subtree=True,
                access_level="ANY"
            )
            
            for compartment in list_compartments_response.data:
                compartments.append({
                    'id': compartment.id,
                    'name': compartment.name,
                    'description': compartment.description,
                    'lifecycle_state': compartment.lifecycle_state,
                    'time_created': compartment.time_created
                })
            
            # Add root compartment (tenancy)
            get_tenancy_response = identity_client.get_tenancy(tenancy_id=self.tenant_id)
            tenancy = get_tenancy_response.data
            compartments.insert(0, {
                'id': tenancy.id,
                'name': f"Root ({tenancy.name})",
                'description': tenancy.description,
                'lifecycle_state': 'ACTIVE',
                'time_created': None
            })
            
            return compartments
            
        except Exception as e:
            print(f"Error retrieving compartments: {e}")
            return []
    
    def get_full_dataset_paginated(
        self,
        start_date: str,
        end_date: str,
        emission_type: str = "LOCATION_BASED",
        calculation_method: str = "POWER_BASED",
        granularity: str = "DAILY",
        group_by: Optional[List[str]] = None,
        compartment_depth: int = 7,
        max_records: Optional[int] = None
    ) -> Dict:
        """
        Retrieve the complete carbon emissions dataset with pagination support.
        Similar to Azure's full carbon emissions export.
        
        Args:
            start_date: Start date in ISO format
            end_date: End date in ISO format  
            emission_type: "LOCATION_BASED" or "MARKET_BASED"
            calculation_method: "POWER_BASED" or "SPEND_BASED"
            granularity: "DAILY" or "MONTHLY"
            group_by: List of fields to group by for maximum detail
            compartment_depth: Compartment depth level
            max_records: Maximum number of records to retrieve (None for all)
            
        Returns:
            Dictionary containing all carbon emissions data
        """
        
        print(f"Retrieving full carbon emissions dataset from {start_date} to {end_date}...")
        print("This may take several minutes for large datasets...")
        
        all_items = []
        page_token = None
        page_count = 0
        total_records = 0
        
        # Set comprehensive group_by for full dataset if not provided
        if group_by is None:
            group_by = ['service', 'compartmentName', 'compartmentId', 'region', 
                       'platform', 'tenantId', 'subscriptionId']
        
        try:
            while True:
                page_count += 1
                print(f"Fetching page {page_count}... (Records so far: {total_records})")
                
                # Get this page of data
                data = self.get_carbon_emissions(
                    start_date=start_date,
                    end_date=end_date,
                    emission_type=emission_type,
                    calculation_method=calculation_method,
                    granularity=granularity,
                    group_by=group_by,
                    compartment_depth=compartment_depth,
                    limit=500,  # Max allowed limit is 500
                    is_aggregate_by_time=False
                )
                
                if data.items:
                    all_items.extend(data.items)
                    total_records += len(data.items)
                    print(f"Retrieved {len(data.items)} records on page {page_count}")
                    
                    # Check if we've reached the max records limit
                    if max_records and total_records >= max_records:
                        print(f"Reached maximum record limit of {max_records}")
                        all_items = all_items[:max_records]
                        break
                else:
                    print(f"No data returned on page {page_count}")
                
                # Check for more pages
                page_token = getattr(data, 'opc_next_page', None)
                if not page_token:
                    print("No more pages available")
                    break
                    
                # Prevent infinite loops
                if page_count >= 1000:
                    print("Maximum page limit reached (1000 pages)")
                    break
            
            print(f"\nCompleted! Retrieved {total_records} total records across {page_count} pages")
            
            # Create a combined result object
            class CombinedResult:
                def __init__(self, items):
                    self.items = items
                    self.opc_request_id = None
                    self.opc_next_page = None
            
            return CombinedResult(all_items)
            
        except Exception as e:
            print(f"Error during full dataset retrieval: {e}")
            if all_items:
                print(f"Returning partial dataset with {len(all_items)} records")
                return CombinedResult(all_items)
            else:
                raise
    
    def print_compartment_list(self):
        """Print a formatted list of all compartments."""
        compartments = self.get_compartment_list()
        
        if not compartments:
            print("No compartments found or unable to retrieve compartments.")
            return
        
        print("\n" + "="*80)
        print("AVAILABLE COMPARTMENTS")
        print("="*80)
        print(f"{'Name':<30} {'ID':<50} {'State':<10}")
        print("-" * 80)
        
        for compartment in compartments:
            name = compartment['name'][:29]
            comp_id = compartment['id']
            state = compartment['lifecycle_state']
            print(f"{name:<30} {comp_id:<50} {state:<10}")
        
        print(f"\nTotal compartments: {len(compartments)}")
        print("-" * 80)

    def validate_group_by_fields(self, group_by: List[str], calculation_method: str) -> List[str]:
        """
        Validate and filter groupBy fields based on calculation method.
        
        Args:
            group_by: List of requested groupBy fields
            calculation_method: 'POWER_BASED' or 'SPEND_BASED'
            
        Returns:
            List of valid groupBy fields for the calculation method
        """
        # Power-based supported fields (based on API error)
        power_based_supported = [
            'service', 'compartmentName', 'compartmentId', 'region', 
            'tenantId', 'tenantName', 'subscriptionId'
        ]
        
        # Spend-based supported fields (more permissive)
        spend_based_supported = [
            'service', 'compartmentName', 'compartmentId', 'region', 
            'tenantId', 'tenantName', 'subscriptionId', 'platform',
            'resourceId', 'resourceName', 'skuName', 'skuPartNumber'
        ]
        
        if calculation_method == 'POWER_BASED':
            supported_fields = power_based_supported
            unsupported = [field for field in group_by if field not in supported_fields]
            if unsupported:
                print(f"Warning: Removing unsupported fields for POWER_BASED: {unsupported}")
            valid_fields = [field for field in group_by if field in supported_fields]
        else:  # SPEND_BASED
            supported_fields = spend_based_supported
            valid_fields = [field for field in group_by if field in supported_fields]
        
        # Ensure we have at least one field
        if not valid_fields:
            print("Warning: No valid groupBy fields found. Using 'service' as default.")
            valid_fields = ['service']
        
        # Limit to 4 fields (API constraint)
        if len(valid_fields) > 4:
            print(f"Warning: Too many groupBy fields ({len(valid_fields)}). Limiting to first 4.")
            valid_fields = valid_fields[:4]
        
        return valid_fields

def calculate_first_day_date_range(period_type: str):
    """
    Calculate date range ensuring both start and end dates are first day of month.
    
    Args:
        period_type: 'last_month' or 'last_3_months'
        
    Returns:
        Tuple of (start_date_str, end_date_str) where both are first day of month
    """
    today = datetime.now()
    
    if period_type == 'last_month':
        # Get first day of current month
        current_month_start = today.replace(day=1)
        # Get first day of previous month
        if current_month_start.month == 1:
            start_date = current_month_start.replace(year=current_month_start.year - 1, month=12)
        else:
            start_date = current_month_start.replace(month=current_month_start.month - 1)
        
        # End date is first day of current month
        end_date = current_month_start
        
    elif period_type == 'last_3_months':
        # Get first day of current month
        current_month_start = today.replace(day=1)
        
        # Get first day 3 months ago
        year = current_month_start.year
        month = current_month_start.month - 3
        
        if month <= 0:
            month += 12
            year -= 1
            
        start_date = datetime(year, month, 1)
        
        # End date is first day of current month
        end_date = current_month_start
    
    return start_date.strftime("%Y-%m-%d"), end_date.strftime("%Y-%m-%d")

def main():
    """Main function to handle command line arguments and execute the script."""
    
    parser = argparse.ArgumentParser(
        description="Retrieve carbon emissions data from Oracle Cloud Infrastructure",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  # Get last month's emissions
  python oci_carbon_emissions.py --last-month
  
  # Get emissions for specific date range
  python oci_carbon_emissions.py --start-date 2024-01-01 --end-date 2024-01-31
  
  # Get emissions grouped by service and region, save to CSV
  python oci_carbon_emissions.py --start-date 2024-01-01 --end-date 2024-01-31 \\
    --group-by service region --output emissions.csv
  
  # Get emissions by compartments with detailed breakdown
  python oci_carbon_emissions.py --start-date 2024-01-01 --end-date 2024-01-31 \\
    --by-compartments --output compartment_emissions.csv
  
  # Filter by specific compartments
  python oci_carbon_emissions.py --start-date 2024-01-01 --end-date 2024-01-31 \\
    --compartments ocid1.compartment.oc1..xxx ocid1.compartment.oc1..yyy
  
  # Download full dataset (similar to Azure carbon emissions export)
  python oci_carbon_emissions.py --last-month --full-dataset
  
  # Get raw data without any grouping (most detailed)
  python oci_carbon_emissions.py --start-date 2024-01-01 --end-date 2024-01-31 --no-grouping
  
  # Download 3 months of full dataset with custom filename
  python oci_carbon_emissions.py --last-3-months --full-dataset --output my_full_emissions.csv
        """
    )
    
    # Date range options
    date_group = parser.add_mutually_exclusive_group(required=True)
    date_group.add_argument('--start-date', 
                           help='Start date (YYYY-MM-DD or ISO format)')
    date_group.add_argument('--last-month', action='store_true',
                           help='Get data for last month')
    date_group.add_argument('--last-3-months', action='store_true',
                           help='Get data for last 3 months')
    
    parser.add_argument('--end-date', 
                       help='End date (YYYY-MM-DD or ISO format). Required if using --start-date')
    
    # API configuration options
    parser.add_argument('--emission-type', 
                       choices=['LOCATION_BASED', 'MARKET_BASED'],
                       default='LOCATION_BASED',
                       help='Type of emission calculation (default: LOCATION_BASED)')
    
    parser.add_argument('--calculation-method',
                       choices=['POWER_BASED', 'SPEND_BASED'],
                       default='POWER_BASED',
                       help='Calculation method (default: POWER_BASED)')
    
    parser.add_argument('--granularity',
                       choices=['DAILY', 'MONTHLY'],
                       default='MONTHLY',
                       help='Data granularity (default: MONTHLY)')
    
    parser.add_argument('--group-by', nargs='+',
                        choices=['service', 'region', 'compartmentName', 'compartmentId',
                                'tenantId', 'tenantName', 'subscriptionId', 'platform',
                                'resourceId', 'resourceName', 'skuName', 'skuPartNumber'],
                        default=['service'],
                        help='Fields to group by (default: service). Power-based supports: service, region, compartmentName, compartmentId, tenantId, tenantName, subscriptionId. Spend-based additionally supports: platform, resourceId, resourceName, skuName, skuPartNumber.')
        
    # Compartment-specific options
    parser.add_argument('--compartments', nargs='+',
                       help='Specific compartment IDs to filter by')
    
    parser.add_argument('--list-compartments', action='store_true',
                       help='List all available compartments and exit')
    
    parser.add_argument('--by-compartments', action='store_true',
                       help='Group results by compartments and show compartment breakdown')
    
    parser.add_argument('--compartment-depth', type=int,
                       help='Compartment depth level to include')
    
    parser.add_argument('--limit', type=int,
                       help='Maximum number of records to return')
    
    parser.add_argument('--aggregate-by-time', action='store_true',
                       help='Aggregate all emissions over the time period')
    
    parser.add_argument('--full-dataset', action='store_true',
                       help='Download full dataset with all available details (similar to Azure carbon emissions export)')
    
    parser.add_argument('--full-dataset-spend-based', action='store_true',
                       help='Download full dataset using spend-based calculations (supports more groupBy fields)')
    
    parser.add_argument('--no-grouping', action='store_true',
                       help='Retrieve raw data without any grouping (most detailed view)')
    
    parser.add_argument('--multi-query-dataset', action='store_true',
                       help='Run multiple queries with different groupBy combinations to get comprehensive data')
    
    # OCI configuration options
    parser.add_argument('--config-file',
                       help='Path to OCI config file (default: ~/.oci/config)')
    
    parser.add_argument('--profile', default='DEFAULT',
                       help='OCI config profile to use (default: DEFAULT)')
    
    # Output options
    parser.add_argument('--output',
                       help='Output file (CSV or JSON based on extension)')
    
    parser.add_argument('--format',
                       choices=['csv', 'json'],
                       help='Output format (auto-detected from --output extension)')
    
    args = parser.parse_args()
    
    # Handle list compartments option
    if args.list_compartments:
        try:
            retriever = OCICarbonEmissionsRetriever(
                config_file=args.config_file,
                profile=args.profile
            )
            retriever.print_compartment_list()
            return
        except Exception as e:
            print(f"Error: {e}")
            sys.exit(1)
    
    # Validate groupBy fields based on calculation method
    power_based_fields = ['service', 'region', 'compartmentName', 'compartmentId', 
                        'tenantId', 'tenantName', 'subscriptionId']
    spend_based_only_fields = ['platform', 'resourceId', 'resourceName', 'skuName', 'skuPartNumber']

    if args.calculation_method == 'POWER_BASED':
        invalid_fields = [field for field in args.group_by if field in spend_based_only_fields]
        if invalid_fields:
            print(f"Warning: Fields {invalid_fields} are not supported with POWER_BASED calculation.")
            print("These fields only work with SPEND_BASED calculation method.")
            print("Either use --calculation-method SPEND_BASED or remove these fields.")
            # Filter out invalid fields
            args.group_by = [field for field in args.group_by if field not in spend_based_only_fields]
            if not args.group_by:
                args.group_by = ['service']
            print(f"Using valid fields: {args.group_by}")
    
    # Set default group_by for compartment analysis
    if args.by_compartments and not args.group_by:
        args.group_by = ['compartmentName', 'service']
    elif args.by_compartments and 'compartmentName' not in args.group_by:
        args.group_by.insert(0, 'compartmentName')
    
    # Set default compartment depth when compartment grouping is used
    if ('compartmentName' in args.group_by or 'compartmentId' in args.group_by) and args.compartment_depth is None:
        args.compartment_depth = 6  # Default to 6 levels deep to include most compartment structures
    
    # Validate compartment depth doesn't exceed API limit
    if args.compartment_depth and args.compartment_depth > 7:
        print(f"Warning: compartmentDepth {args.compartment_depth} exceeds maximum allowed (7). Setting to 7.")
        args.compartment_depth = 7
    
    # Handle full dataset option
    if args.full_dataset:
        print("Full dataset mode enabled - retrieving all available details...")
        # Use only supported fields for power-based carbon emissions (no platform field)
        args.group_by = ['service', 'compartmentName', 'region']
        args.granularity = 'MONTHLY'
        args.compartment_depth = 7  # Maximum allowed depth
        if not args.output:
            args.output = f"oci_full_carbon_emissions_{datetime.now().strftime('%Y%m%d_%H%M%S')}.csv"
            print(f"Auto-setting output file to: {args.output}")
        print("Note: Using power-based supported fields (removed 'platform')")
    
    # Handle full dataset with spend-based calculations (supports more fields)
    if args.full_dataset_spend_based:
        print("Full dataset mode (spend-based) enabled - retrieving all available details...")
        args.calculation_method = 'SPEND_BASED'
        args.emission_type = 'MARKET_BASED'  # Required for spend-based calculations
        # Spend-based supports more groupBy fields but still limited to 4
        args.group_by = ['service', 'compartmentName', 'resourceId', 'skuName']
        args.granularity = 'MONTHLY'
        args.compartment_depth = 7
        if not args.output:
            args.output = f"oci_full_carbon_emissions_spend_based_{datetime.now().strftime('%Y%m%d_%H%M%S')}.csv"
            print(f"Auto-setting output file to: {args.output}")
            print("Note: Using MARKET_BASED emissions (required for spend-based calculations)")
            print("Note: Limited to 4 groupBy fields due to API constraints")
    
    # Handle multi-query dataset option
    if args.multi_query_dataset:
        print("Multi-query dataset mode enabled - running multiple queries for comprehensive data...")
        # We'll handle this in the main execution section
        pass
    
    # Handle no-grouping option for raw data
    if args.no_grouping:
        print("No-grouping mode enabled - retrieving raw data without aggregation...")
        # Use only supported fields for power-based carbon emissions (no platform field)
        args.group_by = ['service', 'compartmentName', 'region']
        args.granularity = 'DAILY'
        args.compartment_depth = 7  # Maximum allowed depth
        if not args.output:
            args.output = f"oci_raw_carbon_emissions_{datetime.now().strftime('%Y%m%d_%H%M%S')}.csv"
            print(f"Auto-setting output file to: {args.output}")
        print("Note: Removed 'platform' field as it's not supported for power-based calculations")
    
    # Calculate date range using first-day-of-month logic
    if args.last_month:
        start_date_str, end_date_str = calculate_first_day_date_range('last_month')
        print(f"Last month date range: {start_date_str} to {end_date_str}")
    elif args.last_3_months:
        start_date_str, end_date_str = calculate_first_day_date_range('last_3_months')
        print(f"Last 3 months date range: {start_date_str} to {end_date_str}")
    else:
        start_date_str = args.start_date
        end_date_str = args.end_date
    
    # Validate that provided dates are first day of month
    try:
        start_dt = datetime.strptime(start_date_str, "%Y-%m-%d")
        end_dt = datetime.strptime(end_date_str, "%Y-%m-%d")
        
        if start_dt.day != 1:
            print(f"Warning: Start date {start_date_str} is not the first day of the month.")
            print(f"OCI API requires first day of month. Adjusting to: {start_dt.replace(day=1).strftime('%Y-%m-%d')}")
            start_date_str = start_dt.replace(day=1).strftime('%Y-%m-%d')
            
        if end_dt.day != 1:
            print(f"Warning: End date {end_date_str} is not the first day of the month.")
            print(f"OCI API requires first day of month. Adjusting to: {end_dt.replace(day=1).strftime('%Y-%m-%d')}")
            end_date_str = end_dt.replace(day=1).strftime('%Y-%m-%d')
            
    except ValueError:
        print("Error: Invalid date format. Please use YYYY-MM-DD format.")
        sys.exit(1)
    
    try:
        # Initialize the retriever
        retriever = OCICarbonEmissionsRetriever(
            config_file=args.config_file,
            profile=args.profile
        )
        
        # Get carbon emissions data
        if args.multi_query_dataset:
            # Run multiple queries with different groupBy combinations
            print("Running multiple queries to get comprehensive dataset...")
            
            # Define different combinations for power-based vs spend-based
            if args.full_dataset_spend_based:
                query_combinations = [
                    (['service', 'compartmentName', 'resourceId', 'skuName'], 'spend_based_service_compartment_resource_sku'),
                    (['service', 'compartmentName', 'platform', 'region'], 'spend_based_service_compartment_platform_region'),
                    (['compartmentName', 'resourceId', 'skuName', 'region'], 'spend_based_compartment_resource_sku_region'),
                    (['service', 'skuName', 'platform'], 'spend_based_service_sku_platform')
                ]
            else:
                # Power-based supported combinations (no platform, resourceId, skuName)
                query_combinations = [
                    (['service', 'compartmentName', 'region'], 'power_based_service_compartment_region'),
                    (['service', 'compartmentName', 'tenantId'], 'power_based_service_compartment_tenant'),
                    (['service', 'region', 'subscriptionId'], 'power_based_service_region_subscription'),
                    (['service', 'compartmentName'], 'power_based_service_compartment')
                ]
            
            all_data = []
            for i, (group_by_fields, suffix) in enumerate(query_combinations, 1):
                print(f"\nQuery {i}/{len(query_combinations)}: Grouping by {', '.join(group_by_fields)}")
                
                try:
                    # Try POWER_BASED first, then SPEND_BASED if no data
                    data = None
                    
                    # Try POWER_BASED with LOCATION_BASED emissions first
                    try:
                        print(f"  Trying POWER_BASED/LOCATION_BASED...")
                        data = retriever.get_carbon_emissions(
                            start_date=start_date_str,
                            end_date=end_date_str,
                            emission_type='LOCATION_BASED',
                            calculation_method='POWER_BASED',
                            granularity=args.granularity,
                            group_by=group_by_fields,
                            compartment_depth=7
                        )
                        if data.items and any(float(item.computed_carbon_emission or 0) > 0 for item in data.items):
                            print(f"  ✓ Found data with POWER_BASED/LOCATION_BASED")
                        else:
                            print(f"  ✗ No emissions data with POWER_BASED/LOCATION_BASED")
                            data = None
                    except Exception as e:
                        print(f"  ✗ Error with POWER_BASED/LOCATION_BASED: {e}")
                        data = None
                    
                    # If no data, try SPEND_BASED
                    if not data or not data.items:
                        try:
                            print(f"  Trying SPEND_BASED/MARKET_BASED...")
                            data = retriever.get_carbon_emissions(
                                start_date=start_date_str,
                                end_date=end_date_str,
                                emission_type='MARKET_BASED',
                                calculation_method='SPEND_BASED',
                                granularity=args.granularity,
                                group_by=group_by_fields,
                                compartment_depth=7
                            )
                            if data.items:
                                print(f"  ✓ Found data with SPEND_BASED/MARKET_BASED")
                            else:
                                print(f"  ✗ No data with SPEND_BASED/MARKET_BASED")
                        except Exception as e:
                            print(f"  ✗ Error with SPEND_BASED/MARKET_BASED: {e}")
                    
                    if data.items:
                        print(f"Retrieved {len(data.items)} records")
                        
                        # Save each query result separately
                        if args.output:
                            base_name = args.output.rsplit('.', 1)[0]
                            extension = args.output.rsplit('.', 1)[1] if '.' in args.output else 'csv'
                            query_filename = f"{base_name}_{suffix}.{extension}"
                            retriever.save_to_csv(data, query_filename)
                        
                        all_data.extend(data.items)
                    else:
                        print("No data returned for this combination")
                        
                except Exception as e:
                    print(f"Error with groupBy combination {group_by_fields}: {e}")
                    continue
            
            # Create combined dataset
            if all_data:
                class CombinedResult:
                    def __init__(self, items):
                        self.items = items
                
                data = CombinedResult(all_data)
                print(f"\nCombined dataset: {len(all_data)} total records")
            else:
                print("No data retrieved from any query")
                return
                
        elif args.full_dataset or args.no_grouping:
            # Use paginated method for full dataset
            data = retriever.get_full_dataset_paginated(
                start_date=start_date_str,
                end_date=end_date_str,
                emission_type=args.emission_type,
                calculation_method=args.calculation_method,
                granularity=args.granularity,
                group_by=args.group_by,
                compartment_depth=args.compartment_depth
            )
        else:
            # Use regular method for standard queries
            data = retriever.get_carbon_emissions(
                start_date=start_date_str,
                end_date=end_date_str,
                emission_type=args.emission_type,
                calculation_method=args.calculation_method,
                granularity=args.granularity,
                group_by=args.group_by,
                is_aggregate_by_time=args.aggregate_by_time,
                limit=args.limit,
                compartment_ids=args.compartments,
                compartment_depth=args.compartment_depth
            )
        
        # Debug API response structure
        retriever.debug_api_response(data)
        
        # Print summary
        retriever.print_summary(data, group_by_compartments=args.by_compartments)
        
        # Save output if requested
        if args.output:
            # Determine format
            if args.format:
                output_format = args.format
            else:
                # Auto-detect from extension
                if args.output.lower().endswith('.csv'):
                    output_format = 'csv'
                elif args.output.lower().endswith('.json'):
                    output_format = 'json'
                else:
                    print("Warning: Could not determine format from filename. Using CSV.")
                    output_format = 'csv'
            
            # Save data
            if output_format == 'csv':
                retriever.save_to_csv(data, args.output)
            else:
                retriever.save_to_json(data, args.output)
    
    except KeyboardInterrupt:
        print("\nOperation cancelled by user.")
        sys.exit(1)
    except Exception as e:
        print(f"Error: {e}")
        sys.exit(1)


if __name__ == "__main__":
    main()
