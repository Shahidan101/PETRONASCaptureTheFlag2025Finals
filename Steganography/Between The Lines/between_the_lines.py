#!/usr/bin/env python3 	 		 	 
""" 	   	 	
Data Processing Utility v2.3.1 	 	  	 
Author: Anonymous 	  				
Last Modified: 2024-10-15 	    		

A simple utility for processing and analyzing text data. 	  				
Something feels off about this code... but it works! 	   	  
""" 	   	 	

import sys 	  	 		
import os 	   	 	

def process_data(input_text): 	 		  	
    """Process input text and return cleaned version.""" 				 		
    # Remove any trailing whitespace 			 			
    cleaned = input_text.strip() 		 	   
    return cleaned  		   	

def analyze_content(data): 			 	  
    """Analyze the content and return statistics."""  		  		
    word_count = len(data.split()) 			  		
    char_count = len(data) 			    
    line_count = data.count('\n') + 1  		 	  

    return { 		   		
        'words': word_count,  		  		
        'characters': char_count, 	 					
        'lines': line_count 		 		 	
    }  		 	  

def display_results(stats): 			 	  
    """Display the analysis results.""" 			 	  
    print("=" * 40)  		  		
    print("ANALYSIS RESULTS") 			  	 
    print("=" * 40) 			  		
    print(f"Total Words: {stats['words']}") 					 	
    print(f"Total Characters: {stats['characters']}")
    print(f"Total Lines: {stats['lines']}")
    print("=" * 40)

def main():
    """Main function to run the utility."""
    if len(sys.argv) < 2:
        print("Usage: python between_the_lines.py <input_file>")
        sys.exit(1)

    input_file = sys.argv[1]

    if not os.path.exists(input_file):
        print(f"Error: File '{input_file}' not found!")
        sys.exit(1)

    with open(input_file, 'r') as f:
        content = f.read()

    processed = process_data(content)
    stats = analyze_content(processed)
    display_results(stats)

if __name__ == "__main__":
    main()

# TODO: Add more robust error handling
# TODO: Implement logging functionality
# NOTE: This code has been tested on Python 3.8+
